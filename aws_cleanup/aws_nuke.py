#!/usr/bin/env python3
"""
AWS Account Cleanup Script
Discovers and deletes all billable AWS resources across all regions.

Usage:
    python aws_nuke.py                  # Dry-run (default) - shows what would be deleted
    python aws_nuke.py --execute        # Actually delete resources
    python aws_nuke.py --region us-east-1  # Target a specific region
"""

import argparse
import sys
import time

import boto3
from botocore.exceptions import ClientError, EndpointConnectionError


RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
CYAN = "\033[96m"
RESET = "\033[0m"


def log(msg, color=RESET):
    print(f"{color}{msg}{RESET}")


def log_found(resource_type, identifier):
    log(f"  [FOUND] {resource_type}: {identifier}", CYAN)


def log_delete(resource_type, identifier, dry_run):
    if dry_run:
        log(f"  [DRY-RUN] Would delete {resource_type}: {identifier}", YELLOW)
    else:
        log(f"  [DELETING] {resource_type}: {identifier}", RED)


def log_skip(resource_type, identifier, reason):
    log(f"  [SKIP] {resource_type}: {identifier} ({reason})", GREEN)


def get_all_regions(session):
    ec2 = session.client("ec2", region_name="us-east-1")
    return [r["RegionName"] for r in ec2.describe_regions()["Regions"]]


# ---------------------------------------------------------------------------
# EC2 Instances
# ---------------------------------------------------------------------------
def cleanup_ec2_instances(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    reservations = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running", "stopped", "pending"]}]
    )["Reservations"]

    for res in reservations:
        for inst in res["Instances"]:
            iid = inst["InstanceId"]
            log_delete("EC2 Instance", iid, dry_run)
            if not dry_run:
                try:
                    ec2.modify_instance_attribute(InstanceId=iid, DisableApiTermination={"Value": False})
                except ClientError:
                    pass
                ec2.terminate_instances(InstanceIds=[iid])


# ---------------------------------------------------------------------------
# EBS Volumes (unattached)
# ---------------------------------------------------------------------------
def cleanup_ebs_volumes(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    volumes = ec2.describe_volumes(Filters=[{"Name": "status", "Values": ["available"]}])["Volumes"]
    for vol in volumes:
        vid = vol["VolumeId"]
        log_delete("EBS Volume", vid, dry_run)
        if not dry_run:
            ec2.delete_volume(VolumeId=vid)


# ---------------------------------------------------------------------------
# EBS Snapshots (owned by self)
# ---------------------------------------------------------------------------
def cleanup_ebs_snapshots(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    sts = session.client("sts")
    account_id = sts.get_caller_identity()["Account"]
    snapshots = ec2.describe_snapshots(OwnerIds=[account_id])["Snapshots"]
    for snap in snapshots:
        sid = snap["SnapshotId"]
        log_delete("EBS Snapshot", sid, dry_run)
        if not dry_run:
            try:
                ec2.delete_snapshot(SnapshotId=sid)
            except ClientError as e:
                log(f"    Could not delete snapshot {sid}: {e}", RED)


# ---------------------------------------------------------------------------
# Elastic IPs
# ---------------------------------------------------------------------------
def cleanup_elastic_ips(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    addresses = ec2.describe_addresses()["Addresses"]
    for addr in addresses:
        alloc_id = addr.get("AllocationId")
        public_ip = addr.get("PublicIp", "N/A")
        if addr.get("AssociationId"):
            log_delete("EIP Disassociate", public_ip, dry_run)
            if not dry_run:
                ec2.disassociate_address(AssociationId=addr["AssociationId"])
        if alloc_id:
            log_delete("Elastic IP", f"{public_ip} ({alloc_id})", dry_run)
            if not dry_run:
                ec2.release_address(AllocationId=alloc_id)


# ---------------------------------------------------------------------------
# NAT Gateways
# ---------------------------------------------------------------------------
def cleanup_nat_gateways(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    nats = ec2.describe_nat_gateways(
        Filter=[{"Name": "state", "Values": ["available", "pending"]}]
    )["NatGateways"]
    for nat in nats:
        nid = nat["NatGatewayId"]
        log_delete("NAT Gateway", nid, dry_run)
        if not dry_run:
            ec2.delete_nat_gateway(NatGatewayId=nid)


# ---------------------------------------------------------------------------
# Load Balancers (ELBv2 + Classic)
# ---------------------------------------------------------------------------
def cleanup_load_balancers(session, region, dry_run):
    # ALB / NLB
    try:
        elbv2 = session.client("elbv2", region_name=region)
        lbs = elbv2.describe_load_balancers()["LoadBalancers"]
        for lb in lbs:
            arn = lb["LoadBalancerArn"]
            log_delete("Load Balancer (v2)", lb["LoadBalancerName"], dry_run)
            if not dry_run:
                elbv2.delete_load_balancer(LoadBalancerArn=arn)
    except ClientError:
        pass

    # Classic ELB
    try:
        elb = session.client("elb", region_name=region)
        classic_lbs = elb.describe_load_balancers()["LoadBalancerDescriptions"]
        for lb in classic_lbs:
            name = lb["LoadBalancerName"]
            log_delete("Classic Load Balancer", name, dry_run)
            if not dry_run:
                elb.delete_load_balancer(LoadBalancerName=name)
    except ClientError:
        pass


# ---------------------------------------------------------------------------
# Target Groups
# ---------------------------------------------------------------------------
def cleanup_target_groups(session, region, dry_run):
    try:
        elbv2 = session.client("elbv2", region_name=region)
        tgs = elbv2.describe_target_groups()["TargetGroups"]
        for tg in tgs:
            arn = tg["TargetGroupArn"]
            log_delete("Target Group", tg["TargetGroupName"], dry_run)
            if not dry_run:
                try:
                    elbv2.delete_target_group(TargetGroupArn=arn)
                except ClientError:
                    pass
    except ClientError:
        pass


# ---------------------------------------------------------------------------
# RDS Instances & Clusters
# ---------------------------------------------------------------------------
def cleanup_rds(session, region, dry_run):
    rds = session.client("rds", region_name=region)

    # DB Instances
    instances = rds.describe_db_instances()["DBInstances"]
    for db in instances:
        dbid = db["DBInstanceIdentifier"]
        log_delete("RDS Instance", dbid, dry_run)
        if not dry_run:
            try:
                rds.modify_db_instance(DBInstanceIdentifier=dbid, DeletionProtection=False)
            except ClientError:
                pass
            rds.delete_db_instance(
                DBInstanceIdentifier=dbid,
                SkipFinalSnapshot=True,
                DeleteAutomatedBackups=True,
            )

    # DB Clusters (Aurora)
    clusters = rds.describe_db_clusters()["DBClusters"]
    for cl in clusters:
        cid = cl["DBClusterIdentifier"]
        log_delete("RDS Cluster", cid, dry_run)
        if not dry_run:
            try:
                rds.modify_db_cluster(DBClusterIdentifier=cid, DeletionProtection=False)
            except ClientError:
                pass
            rds.delete_db_cluster(DBClusterIdentifier=cid, SkipFinalSnapshot=True)


# ---------------------------------------------------------------------------
# Lambda Functions
# ---------------------------------------------------------------------------
def cleanup_lambda(session, region, dry_run):
    lam = session.client("lambda", region_name=region)
    funcs = lam.list_functions()["Functions"]
    for fn in funcs:
        name = fn["FunctionName"]
        log_delete("Lambda Function", name, dry_run)
        if not dry_run:
            lam.delete_function(FunctionName=name)


# ---------------------------------------------------------------------------
# S3 Buckets (global, but region-filtered)
# ---------------------------------------------------------------------------
def cleanup_s3(session, dry_run):
    s3 = session.client("s3")
    s3_resource = session.resource("s3")
    buckets = s3.list_buckets().get("Buckets", [])

    for bucket in buckets:
        name = bucket["Name"]
        log_delete("S3 Bucket", name, dry_run)
        if not dry_run:
            try:
                b = s3_resource.Bucket(name)
                b.object_versions.all().delete()
                b.objects.all().delete()
                b.delete()
            except ClientError as e:
                log(f"    Could not delete bucket {name}: {e}", RED)


# ---------------------------------------------------------------------------
# VPC and networking (subnets, IGW, route tables, security groups, endpoints)
# ---------------------------------------------------------------------------
def cleanup_vpcs(session, region, dry_run):
    ec2 = session.client("ec2", region_name=region)
    ec2r = session.resource("ec2", region_name=region)
    vpcs = ec2.describe_vpcs()["Vpcs"]

    for vpc_data in vpcs:
        vpc_id = vpc_data["VpcId"]
        is_default = vpc_data.get("IsDefault", False)

        if is_default:
            log_skip("VPC", vpc_id, "default VPC — skipped for safety")
            continue

        log(f"\n  Cleaning VPC: {vpc_id}", CYAN)
        vpc = ec2r.Vpc(vpc_id)

        # VPC Endpoints
        endpoints = ec2.describe_vpc_endpoints(
            Filters=[{"Name": "vpc-id", "Values": [vpc_id]}]
        )["VpcEndpoints"]
        for ep in endpoints:
            epid = ep["VpcEndpointId"]
            log_delete("VPC Endpoint", epid, dry_run)
            if not dry_run:
                ec2.delete_vpc_endpoints(VpcEndpointIds=[epid])

        # Internet Gateways
        igws = ec2.describe_internet_gateways(
            Filters=[{"Name": "attachment.vpc-id", "Values": [vpc_id]}]
        )["InternetGateways"]
        for igw in igws:
            igw_id = igw["InternetGatewayId"]
            log_delete("Internet Gateway", igw_id, dry_run)
            if not dry_run:
                ec2.detach_internet_gateway(InternetGatewayId=igw_id, VpcId=vpc_id)
                ec2.delete_internet_gateway(InternetGatewayId=igw_id)

        # Subnets
        for subnet in vpc.subnets.all():
            log_delete("Subnet", subnet.id, dry_run)
            if not dry_run:
                subnet.delete()

        # Route Tables (non-main)
        for rt in vpc.route_tables.all():
            main = any(a.get("Main", False) for a in rt.associations_attribute or [])
            if main:
                continue
            log_delete("Route Table", rt.id, dry_run)
            if not dry_run:
                for assoc in rt.associations_attribute or []:
                    if not assoc.get("Main", False):
                        ec2.disassociate_route_table(AssociationId=assoc["RouteTableAssociationId"])
                rt.delete()

        # Network ACLs (non-default)
        for acl in vpc.network_acls.all():
            if acl.is_default:
                continue
            log_delete("Network ACL", acl.id, dry_run)
            if not dry_run:
                acl.delete()

        # Security Groups (non-default)
        for sg in vpc.security_groups.all():
            if sg.group_name == "default":
                continue
            log_delete("Security Group", sg.id, dry_run)
            if not dry_run:
                try:
                    sg.revoke_ingress(IpPermissions=sg.ip_permissions) if sg.ip_permissions else None
                    sg.revoke_egress(IpPermissions=sg.ip_permissions_egress) if sg.ip_permissions_egress else None
                except ClientError:
                    pass
                sg.delete()

        # Delete VPC
        log_delete("VPC", vpc_id, dry_run)
        if not dry_run:
            try:
                ec2.delete_vpc(VpcId=vpc_id)
            except ClientError as e:
                log(f"    Could not delete VPC {vpc_id}: {e}", RED)


# ---------------------------------------------------------------------------
# ECS Clusters & Services
# ---------------------------------------------------------------------------
def cleanup_ecs(session, region, dry_run):
    ecs = session.client("ecs", region_name=region)
    clusters = ecs.list_clusters()["clusterArns"]
    for cluster_arn in clusters:
        cluster_name = cluster_arn.split("/")[-1]

        # Stop services first
        services = ecs.list_services(cluster=cluster_arn)["serviceArns"]
        for svc_arn in services:
            log_delete("ECS Service", svc_arn.split("/")[-1], dry_run)
            if not dry_run:
                ecs.update_service(cluster=cluster_arn, service=svc_arn, desiredCount=0)
                ecs.delete_service(cluster=cluster_arn, service=svc_arn, force=True)

        # Stop running tasks
        tasks = ecs.list_tasks(cluster=cluster_arn)["taskArns"]
        for task_arn in tasks:
            log_delete("ECS Task", task_arn.split("/")[-1], dry_run)
            if not dry_run:
                ecs.stop_task(cluster=cluster_arn, task=task_arn)

        log_delete("ECS Cluster", cluster_name, dry_run)
        if not dry_run:
            ecs.delete_cluster(cluster=cluster_arn)


# ---------------------------------------------------------------------------
# CloudWatch Log Groups
# ---------------------------------------------------------------------------
def cleanup_cloudwatch_logs(session, region, dry_run):
    logs = session.client("logs", region_name=region)
    paginator = logs.get_paginator("describe_log_groups")
    for page in paginator.paginate():
        for lg in page["logGroups"]:
            name = lg["logGroupName"]
            log_delete("CloudWatch Log Group", name, dry_run)
            if not dry_run:
                logs.delete_log_group(logGroupName=name)


# ---------------------------------------------------------------------------
# ECR Repositories
# ---------------------------------------------------------------------------
def cleanup_ecr(session, region, dry_run):
    ecr = session.client("ecr", region_name=region)
    try:
        repos = ecr.describe_repositories()["repositories"]
        for repo in repos:
            name = repo["repositoryName"]
            log_delete("ECR Repository", name, dry_run)
            if not dry_run:
                ecr.delete_repository(repositoryName=name, force=True)
    except ClientError:
        pass


# ---------------------------------------------------------------------------
# CloudFormation Stacks
# ---------------------------------------------------------------------------
def cleanup_cloudformation(session, region, dry_run):
    cfn = session.client("cloudformation", region_name=region)
    stacks = cfn.list_stacks(StackStatusFilter=["CREATE_COMPLETE", "UPDATE_COMPLETE", "ROLLBACK_COMPLETE"])[
        "StackSummaries"
    ]
    for stack in stacks:
        name = stack["StackName"]
        log_delete("CloudFormation Stack", name, dry_run)
        if not dry_run:
            try:
                cfn.update_termination_protection(EnableTerminationProtection=False, StackName=name)
            except ClientError:
                pass
            cfn.delete_stack(StackName=name)


# ---------------------------------------------------------------------------
# Auto Scaling Groups & Launch Configurations
# ---------------------------------------------------------------------------
def cleanup_autoscaling(session, region, dry_run):
    asg = session.client("autoscaling", region_name=region)

    groups = asg.describe_auto_scaling_groups()["AutoScalingGroups"]
    for g in groups:
        name = g["AutoScalingGroupName"]
        log_delete("Auto Scaling Group", name, dry_run)
        if not dry_run:
            asg.update_auto_scaling_group(AutoScalingGroupName=name, MinSize=0, DesiredCapacity=0)
            asg.delete_auto_scaling_group(AutoScalingGroupName=name, ForceDelete=True)

    lcs = asg.describe_launch_configurations()["LaunchConfigurations"]
    for lc in lcs:
        name = lc["LaunchConfigurationName"]
        log_delete("Launch Configuration", name, dry_run)
        if not dry_run:
            asg.delete_launch_configuration(LaunchConfigurationName=name)


# ---------------------------------------------------------------------------
# ElastiCache
# ---------------------------------------------------------------------------
def cleanup_elasticache(session, region, dry_run):
    ec = session.client("elasticache", region_name=region)
    clusters = ec.describe_cache_clusters()["CacheClusters"]
    for cl in clusters:
        cid = cl["CacheClusterId"]
        log_delete("ElastiCache Cluster", cid, dry_run)
        if not dry_run:
            ec.delete_cache_cluster(CacheClusterId=cid)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="AWS Account Cleanup - delete all billable resources")
    parser.add_argument("--execute", action="store_true", help="Actually delete resources (default is dry-run)")
    parser.add_argument("--region", type=str, help="Target a specific region (default: all regions)")
    parser.add_argument("--profile", type=str, help="AWS CLI profile to use")
    args = parser.parse_args()

    dry_run = not args.execute

    session_kwargs = {}
    if args.profile:
        session_kwargs["profile_name"] = args.profile

    session = boto3.Session(**session_kwargs)
    sts = session.client("sts")

    try:
        identity = sts.get_caller_identity()
    except Exception as e:
        log(f"Failed to authenticate with AWS: {e}", RED)
        sys.exit(1)

    account_id = identity["Account"]
    user_arn = identity["Arn"]

    log("=" * 70, YELLOW)
    if dry_run:
        log("  DRY-RUN MODE — no resources will be deleted", GREEN)
    else:
        log("  EXECUTE MODE — resources WILL BE PERMANENTLY DELETED", RED)
    log(f"  Account:  {account_id}", YELLOW)
    log(f"  Identity: {user_arn}", YELLOW)
    log("=" * 70, YELLOW)

    if not dry_run:
        log("\nYou have 10 seconds to press Ctrl+C to abort...\n", RED)
        time.sleep(10)

    if args.region:
        regions = [args.region]
    else:
        regions = get_all_regions(session)

    # S3 is global
    log(f"\n{'='*50}", CYAN)
    log("S3 Buckets (global)", CYAN)
    log(f"{'='*50}", CYAN)
    cleanup_s3(session, dry_run)

    # Per-region resources
    for region in regions:
        log(f"\n{'='*50}", CYAN)
        log(f"Region: {region}", CYAN)
        log(f"{'='*50}", CYAN)

        cleanups = [
            ("EC2 Instances", cleanup_ec2_instances),
            ("NAT Gateways", cleanup_nat_gateways),
            ("Load Balancers", cleanup_load_balancers),
            ("Target Groups", cleanup_target_groups),
            ("Auto Scaling", cleanup_autoscaling),
            ("ECS", cleanup_ecs),
            ("RDS", cleanup_rds),
            ("ElastiCache", cleanup_elasticache),
            ("Lambda Functions", cleanup_lambda),
            ("ECR Repositories", cleanup_ecr),
            ("CloudFormation Stacks", cleanup_cloudformation),
            ("EBS Snapshots", cleanup_ebs_snapshots),
            ("EBS Volumes", cleanup_ebs_volumes),
            ("Elastic IPs", cleanup_elastic_ips),
            ("CloudWatch Logs", cleanup_cloudwatch_logs),
            ("VPCs & Networking", cleanup_vpcs),
        ]

        for name, func in cleanups:
            log(f"\n  --- {name} ---")
            try:
                func(session, region, dry_run)
            except EndpointConnectionError:
                log(f"    Skipped (endpoint not available in {region})")
            except ClientError as e:
                log(f"    Error: {e}", RED)

    log(f"\n{'='*70}", GREEN)
    if dry_run:
        log("  DRY-RUN COMPLETE. Run with --execute to actually delete resources.", GREEN)
    else:
        log("  CLEANUP COMPLETE.", GREEN)
    log(f"{'='*70}", GREEN)


if __name__ == "__main__":
    main()
