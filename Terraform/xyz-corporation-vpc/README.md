# XYZ Corporation - VPC Infrastructure

This project sets up two separate Amazon VPCs for XYZ Corporation — a **Production Network** and a **Development Network** — connected via VPC Peering.

---

## Architecture Overview

### Production Network (4-Tier Architecture)

```
                    INTERNET
                       |
                  [ IGW: production-igw ]
                       |
         +----------------------------+
         |   WEB SUBNET (Public)      |   10.0.1.0/24  |  ap-south-1a
         |   Instance: production-web  |
         +----------------------------+
                  |            |
     +------------------+  +------------------+
     | APP1 SUBNET      |  | APP2 SUBNET      |
     | (Private + NAT)  |  | (Private, no     |
     | 10.0.2.0/24      |  |  internet)        |
     | ap-south-1a      |  | 10.0.3.0/24      |
     | Instance:        |  | ap-south-1b      |
     |  production-app1 |  | Instance:        |
     +------------------+  |  production-app2 |
              |            +------------------+
              |                     |
     +------------------+  +------------------+
     | DBCACHE SUBNET   |  | DB SUBNET        |
     | (Private + NAT)  |  | (Private, no     |
     | 10.0.4.0/24      |  |  internet)        |
     | ap-south-1a      |  | 10.0.5.0/24      |
     | Instance:        |  | ap-south-1b      |
     |  production-     |  | Instance:        |
     |  dbcache         |  |  production-db   |
     +------------------+  +------------------+
                                    |
                            [ VPC PEERING ]
                                    |
                           Development DB
```

**5 Subnets:**
| Subnet | CIDR | Type | Internet Access | AZ |
|--------|------|------|-----------------|----|
| web | 10.0.1.0/24 | Public | Full (IGW) | ap-south-1a |
| app1 | 10.0.2.0/24 | Private | Outbound only (NAT Gateway) | ap-south-1a |
| app2 | 10.0.3.0/24 | Private | None | ap-south-1b |
| dbcache | 10.0.4.0/24 | Private | Outbound only (NAT Gateway) | ap-south-1a |
| db | 10.0.5.0/24 | Private | None | ap-south-1b |

**Why NAT for app1 and dbcache?** These subnets need to download packages/updates from the internet (outbound), but should NOT be reachable from the internet (inbound). The NAT Gateway sits in the public web subnet and forwards their outbound traffic.

### Development Network (2-Tier Architecture)

```
                    INTERNET
                       |
                  [ IGW: development-igw ]
                       |
         +------------------------------+
         |   WEB SUBNET (Public)        |   10.1.1.0/24  |  ap-south-1a
         |   Instance: development-web  |
         +------------------------------+
                       |
         +------------------------------+
         |   DB SUBNET (Private)        |   10.1.2.0/24  |  ap-south-1b
         |   Instance: development-db   |
         +------------------------------+
                       |
                [ VPC PEERING ]
                       |
                 Production DB
```

**2 Subnets:**
| Subnet | CIDR | Type | Internet Access | AZ |
|--------|------|------|-----------------|----|
| web | 10.1.1.0/24 | Public | Full (IGW) | ap-south-1a |
| db | 10.1.2.0/24 | Private | None | ap-south-1b |

### VPC Peering (DB-to-DB Connectivity)

The two VPCs are connected via a VPC Peering Connection so that the **production DB subnet** (10.0.5.0/24) and **development DB subnet** (10.1.2.0/24) can communicate directly. This is useful for data sync, migration, or cross-environment queries.

---

## Folder Structure

```
xyz-corporation-vpc/
├── README.md                          # This file
├── production-network/
│   ├── providers.tf                   # AWS provider config
│   ├── variables.tf                   # All input variables
│   ├── main.tf                        # VPC, subnets, route tables, SGs, NACLs, EC2s
│   └── outputs.tf                     # VPC ID, subnet IDs, public IPs
└── development-network/
    ├── providers.tf                   # AWS provider config
    ├── variables.tf                   # All input variables
    ├── main.tf                        # VPC, subnets, route tables, SGs, NACLs, EC2s, peering
    ├── outputs.tf                     # VPC ID, subnet IDs, public IPs, peering ID
    └── terraform.tfvars.example       # Example values for production VPC references
```

---

## Prerequisites

Before you start, make sure you have:

1. **Terraform installed** (v1.0+)
   ```bash
   terraform -version
   ```

2. **AWS CLI configured** with your credentials
   ```bash
   aws configure
   # Enter your Access Key ID, Secret Key, Region (ap-south-1), and output format
   ```

3. **An SSH key pair** created in the AWS Console (EC2 > Key Pairs)
   - The project uses the key pair name `06022026`
   - Your `.pem` file should be stored securely (e.g., `C:\AWS\06022026.pem`)

4. **A valid AMI ID** for your region
   - The default is `ami-0f58b397bc5c1f2e8` (Amazon Linux 2 in ap-south-1)
   - Verify it exists: `aws ec2 describe-images --image-ids ami-0f58b397bc5c1f2e8 --region ap-south-1`

---

## Step-by-Step Deployment

### Step 1: Deploy the Production Network (do this FIRST)

The production network must be deployed first because the development network needs its VPC ID and route table ID for peering.

```bash
cd xyz-corporation-vpc/production-network
```

**1a. Initialize Terraform** (downloads the AWS provider plugin)
```bash
terraform init
```

**1b. Preview what will be created**
```bash
terraform plan
```

This shows you every resource Terraform will create. Review it — you should see:
- 1 VPC
- 5 Subnets (web, app1, app2, dbcache, db)
- 1 Internet Gateway
- 1 NAT Gateway + 1 Elastic IP
- 3 Route Tables (public, private-nat, private-isolated)
- 5 Security Groups (one per subnet)
- 5 NACLs (one per subnet)
- 5 EC2 Instances (one per subnet)

**1c. Apply (create the resources)**
```bash
terraform apply
```

Type `yes` when prompted. Wait for it to finish (NAT Gateway takes ~2 minutes).

**1d. Note down the outputs** — you'll need them for the development network
```bash
terraform output
```

Save these values:
- `vpc_id` — e.g., `vpc-07234a12d1f349a06`
- `db_route_table_id` — e.g., `rtb-01a6fdc1978a86272`

### Step 2: Deploy the Development Network

```bash
cd ../development-network
```

**2a. Create your tfvars file** with the production outputs
```bash
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and paste the values from Step 1d:
```hcl
production_vpc_id            = "vpc-07234a12d1f349a06"
production_db_route_table_id = "rtb-01a6fdc1978a86272"
```

**2b. Initialize Terraform**
```bash
terraform init
```

**2c. Preview what will be created**
```bash
terraform plan -var-file="terraform.tfvars"
```

You should see:
- 1 VPC
- 2 Subnets (web, db)
- 1 Internet Gateway
- 2 Route Tables (public, private)
- 2 Security Groups
- 2 NACLs
- 2 EC2 Instances
- 1 VPC Peering Connection
- 2 Routes (one on each side for db-to-db traffic)

**2d. Apply**
```bash
terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted.

### Step 3: Verify in AWS Console

After both deployments, verify in the AWS Console:

1. **VPC Dashboard** — you should see `production-vpc` (10.0.0.0/16) and `development-vpc` (10.1.0.0/16)
2. **Subnets** — 7 total (5 production + 2 development)
3. **EC2 Instances** — 7 total, each named after its subnet
4. **Peering Connections** — 1 active connection named `production-development-peering`
5. **Route Tables** — check that `production-private-isolated-rt` has a route to `10.1.2.0/24` via the peering connection

---

## How Traffic Flows

### Production Network

| From | To | Path |
|------|----|------|
| Internet | Web instance | IGW → Web subnet (public IP) |
| Web | App1 | Direct (same VPC, port 8080) |
| App1 | App2 | Direct (same VPC, port 8080) |
| App1/App2 | DBCache | Direct (same VPC, port 6379) |
| App1/App2/DBCache | DB | Direct (same VPC, port 3306) |
| App1 | Internet (outbound) | App1 → NAT Gateway → IGW |
| DBCache | Internet (outbound) | DBCache → NAT Gateway → IGW |
| App2/DB | Internet | BLOCKED (no route) |

### Development Network

| From | To | Path |
|------|----|------|
| Internet | Web instance | IGW → Web subnet (public IP) |
| Web | DB | Direct (same VPC, port 3306) |
| DB | Internet | BLOCKED (no route, no NAT) |

### Cross-VPC (Peering)

| From | To | Path |
|------|----|------|
| Production DB (10.0.5.x) | Development DB (10.1.2.x) | VPC Peering, port 3306 |
| Development DB (10.1.2.x) | Production DB (10.0.5.x) | VPC Peering, port 3306 |

---

## Key Concepts Explained

### VPC (Virtual Private Cloud)
Your own isolated network in AWS. Think of it as your private data center in the cloud. Each VPC has a CIDR block (IP range) — production uses `10.0.0.0/16` (65,536 IPs) and development uses `10.1.0.0/16`.

### Subnet
A subdivision of a VPC. Each subnet lives in one Availability Zone. **Public subnets** have a route to the Internet Gateway. **Private subnets** don't.

### Internet Gateway (IGW)
The "door" between your VPC and the internet. Attach it to a VPC, then add a route in the route table pointing `0.0.0.0/0` → IGW.

### NAT Gateway
Allows private subnet instances to reach the internet (e.g., to download updates) without being reachable FROM the internet. It lives in a public subnet and translates private IPs to its own public Elastic IP.

### Route Table
A set of rules (routes) that determine where network traffic goes. Each subnet is associated with one route table. Key routes:
- `0.0.0.0/0 → IGW` = "send all internet traffic through the Internet Gateway"
- `0.0.0.0/0 → NAT` = "send all internet traffic through the NAT Gateway"
- `10.1.2.0/24 → pcx-xxx` = "send traffic for dev DB subnet through VPC peering"

### Security Group (SG)
A virtual firewall at the **instance level**. Rules are stateful (if you allow inbound, the response is automatically allowed). We chain them tier-by-tier: Web SG → App1 SG → App2 SG → DB SG.

### Network ACL (NACL)
A virtual firewall at the **subnet level**. Rules are stateless (you must allow both inbound AND return traffic). Acts as a second layer of defense. Rules are evaluated in order by rule number.

### VPC Peering
A networking connection between two VPCs that allows traffic to flow using private IPs. Traffic stays on the AWS backbone (never goes over the internet). Both sides must add routes pointing to each other.

---

## Cleanup (Destroy Resources)

**IMPORTANT:** Destroy development FIRST (it depends on production), then production.

```bash
# Step 1: Destroy development network
cd development-network
terraform destroy -var-file="terraform.tfvars"
# Type "yes"

# Step 2: Destroy production network
cd ../production-network
terraform destroy
# Type "yes"
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| `Error: creating NAT Gateway: timeout` | NAT Gateways take 1-3 minutes. Run `terraform apply` again. |
| `InvalidAMIID.NotFound` | The AMI ID doesn't exist in your region. Find the correct one in EC2 Console > AMIs. |
| `InvalidKeyPair.NotFound` | Create a key pair named `06022026` in EC2 Console > Key Pairs, or update `key_name` in variables.tf. |
| `VpcPeeringConnectionAlreadyExists` | A peering connection already exists. Check VPC > Peering Connections in the console. |
| `terraform output` shows nothing | Run `terraform apply` first. Outputs are only available after resources are created. |

---

## Cost Warning

This project creates resources that cost money:
- **NAT Gateway**: ~$0.045/hour (~$32/month) + data processing charges
- **Elastic IP**: Free while attached to NAT Gateway; $0.005/hour if detached
- **EC2 Instances**: 7x t2.micro (free tier eligible for 1 instance only)

**Run `terraform destroy` when you're done practicing to avoid charges.**
