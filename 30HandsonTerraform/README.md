# 30 Days of Terraform + AWS — DevOps Mastery Track

A hands-on, project-driven challenge to go from zero Terraform to production-grade AWS infrastructure in 30 days. Each day produces a deployable project — real infrastructure you can show in interviews.

The entire track builds around a single **PERN (PostgreSQL + Express + React + Node.js) Todo app**, progressively adding AWS services and DevOps practices until it runs as a fully observable, auto-scaling, multi-region production system.

---

## Goal

By Day 30, have a public GitHub repo that demonstrates:
- Infrastructure as Code with Terraform across 15+ AWS services
- Production networking (custom VPC, ALB, NAT Gateway, HTTPS, bastion)
- CI/CD pipelines (GitHub Actions + OIDC + ECR + blue/green deploys)
- Observability stack (CloudWatch, X-Ray, Synthetics canaries)
- Cost optimization, disaster recovery, and security scanning
- Kubernetes deployment on EKS

This repo **is** the interview. No certificate needed.

---

## Phases

### Phase 1 — Terraform + AWS Core (Days 01–06) `Foundation`

| Day | Project | Key Concepts | Deliverable |
|-----|---------|-------------|-------------|
| 01 | Terraform State + First EC2 | `main.tf`, plan/apply/destroy lifecycle, S3 remote state, DynamoDB locking | EC2 live + S3 backend configured |
| 02 | Variables, Outputs & Modules | `variables.tf`, `outputs.tf`, `terraform.tfvars`, DRY modules | Reusable EC2 module in `/modules/` |
| 03 | IAM Roles, Policies & Least Privilege | IAM role for EC2, instance profile, custom policy JSON, `assume_role_policy` vs resource policy | EC2 accessing S3 via IAM role — no hardcoded credentials |
| 04 | RDS PostgreSQL (Managed DB) | Subnet group, parameter group, automated backups, Multi-AZ, `aws_db_instance` | PERN Todo running against RDS |
| 05 | S3 Static Frontend + CloudFront CDN | S3 static hosting, CloudFront distribution, OAC, cache behaviors, custom error pages | React app on CloudFront — globally distributed |
| 06 | Workspaces: Dev / Staging / Prod | `terraform workspace`, `terraform.workspace` in locals, workspaces vs separate backends | 3-environment setup from same `.tf` files |

### Phase 2 — Networking + Security (Days 07–13) `VPC Mastery`

| Day | Project | Key Concepts | Deliverable |
|-----|---------|-------------|-------------|
| 07 | Custom VPC from Scratch | CIDR blocks, public + private subnets across 2 AZs, Internet Gateway, route tables, subnet routing vs security groups | Custom VPC with 4 subnets (2 pub / 2 priv) |
| 08 | ALB + Target Groups + Health Checks | Application Load Balancer, target groups, listener rules, ALB vs NLB vs Classic | ALB + private EC2 working |
| 09 | NAT Gateway + Private Subnet Internet | NAT Gateway vs NAT Instance, Elastic IP, private subnet route table | Private EC2 can curl internet, not reachable from internet |
| 10 | Security Groups vs NACLs Deep Dive | 3-tier security model (ALB SG, App SG, DB SG), NACLs, stateful vs stateless | Full 3-tier security model documented + applied |
| 11 | AWS Secrets Manager + Parameter Store | Secrets Manager vs SSM Parameter Store, fetching secrets in Node.js at startup, secret rotation | Zero credentials in codebase or EC2 env files |
| 12 | ACM SSL Certificate + HTTPS Everywhere | ACM cert, DNS validation, Route 53 hosted zone, A-record alias to ALB, HTTP → HTTPS redirect | Todo app on custom domain with valid HTTPS |
| 13 | VPC Peering + Bastion Host | Bastion EC2, SSM Session Manager (no port 22), VPC peering, route propagation, CIDR conflict prevention | Secure DB access without public exposure |

### Phase 3 — CI/CD + Automation (Days 14–21) `Pipeline Engineering`

| Day | Project | Key Concepts | Deliverable |
|-----|---------|-------------|-------------|
| 14 | Terraform in GitHub Actions | GH Actions workflow: `fmt` → `validate` → `plan` on PR, `apply` on merge, OIDC auth to AWS | Infra changes reviewed in PR before applying |
| 15 | Auto Scaling Groups + Launch Templates | ASG, Launch Template with user-data, scale-out on CPU > 70%, ASG to ALB Target Group | App auto-scales under load, auto-registers with ALB |
| 16 | Blue/Green Deployments | Two ASGs, ALB weighted target groups, 0% → smoke tests → 100% → destroy old | Prod deploy with no downtime, instant rollback |
| 17 | Docker + ECR Image Pipeline | Multi-stage Dockerfile, GH Actions build + tag + push to ECR, lifecycle policy (keep last 10) | Docker image in ECR, deploy pulls latest tag |
| 18 | Lambda + API Gateway (Serverless) | Node.js Lambda via `aws_lambda_function`, API Gateway POST `/notify`, Lambda layers | Serverless notification endpoint working |
| 19 | RDS Read Replica + Connection Pooling | Read replica, `pg` routing reads to replica / writes to primary, RDS Proxy | Read/write split with connection pooling |
| 20 | ElastiCache Redis + Caching Layer | ElastiCache Redis cluster, cache-aside pattern for GET `/todos`, TTL, cache invalidation on write | API response time drops 10x on cache hit |
| 21 | SQS + Async Job Queue | SQS queue, Lambda consumer, Dead Letter Queue, visibility timeout, retry logic | Async CSV import without blocking the API |

### Phase 4 — Observability (Days 22–25) `Monitoring + Alerting`

| Day | Project | Key Concepts | Deliverable |
|-----|---------|-------------|-------------|
| 22 | CloudWatch Metrics + Alarms + Dashboards | CloudWatch dashboard, `aws_cloudwatch_metric_alarm`, SNS email alerts, custom metrics from Node.js | Dashboard live, email alert on 5xx spike |
| 23 | Centralized Logging with CloudWatch Logs | CloudWatch Agent, ALB access logs to S3 + Athena, Log Insights queries, retention policies, structured JSON logs | Query "all 500 errors in last 1h" in seconds |
| 24 | X-Ray Distributed Tracing | X-Ray SDK in Express, instrument RDS + Redis + outbound HTTP, X-Ray Service Map | Full trace from HTTP request to DB query visible |
| 25 | Synthetic Canary Monitoring | CloudWatch Synthetics canary, Route 53 health checks on ALB, incident simulation, runbooks | Uptime monitoring + incident response runbook |

### Phase 5 — Production Architecture (Days 26–30) `Ship It`

| Day | Project | Key Concepts | Deliverable |
|-----|---------|-------------|-------------|
| 26 | Multi-Region Disaster Recovery | Standby region (us-west-2), RDS cross-region read replica, Route 53 health-check failover, S3 cross-region replication, RTO/RPO | Manual failover to us-west-2 in under 5 minutes |
| 27 | AWS Cost Optimization | Reserved Instances vs Savings Plans, Spot Instances for non-prod ASG, S3 lifecycle policies, Compute Optimizer, tagging for cost allocation | Cost reduced 40%+ with same architecture |
| 28 | EKS: Deploy PERN App to Kubernetes | EKS cluster with Terraform (eksctl optional), Deployment + Service + Ingress manifests, AWS Load Balancer Controller, ECR image | PERN backend running in EKS pod, accessible via ALB |
| 29 | Terraform Compliance + Security Scanning | tfsec, checkov, `terraform-docs`, Sentinel-style policy-as-code, prevent unrestricted security groups | Pipeline blocks insecure infra automatically |
| 30 | Portfolio: Document + Present Everything | Architecture README with diagrams (draw.io or Mermaid), "What I learned + what broke + how I fixed it" per phase | Public GitHub repo — production-grade README + architecture diagram |

---

## Daily Routine

- **30 min** — Read Terraform docs / AWS service page for the day
- **2–3 hrs** — Build the project hands-on, break things deliberately
- **30 min** — Write a 3-sentence reflection: what broke, why, how fixed
- **15 min** — Prep 2 interview Q&As from the day's concepts
- **End of day** — Destroy resources to control costs

---

## Repo Structure

```
30HandsonTerraform/
├── day-01/          # Each day is a self-contained project
├── day-02/
├── ...
├── day-30/
├── modules/         # Reusable Terraform modules (from Day 02+)
└── README.md
```

---

## Prerequisites

- AWS account (free tier covers most of Days 01–06)
- Terraform CLI installed
- AWS CLI configured with credentials
- Git + GitHub account
- Node.js (for the PERN app)
- Docker (from Day 17+)

---

## Why This Track

- You understand PERN apps at runtime — use this to explain WHY infra is designed as it is
- You know how DB connections behave — RDS Proxy, connection pooling questions are yours to own
- You've debugged 500 errors — your CloudWatch + tracing setup will reflect this depth
- Target interviews at companies using Node.js backends on AWS — you'll speak their language
- By Day 30, your GitHub repo IS your interview. No certificate needed.
