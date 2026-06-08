# EC2 Instance with SSM Session Manager — Terraform

Launch an EC2 instance on AWS and connect to it **without SSH keys** using AWS Systems Manager (SSM) Session Manager. This is the production-recommended approach.

---

## Why SSM Instead of SSH Keys?

| Approach | Security | Key Management | Audit Logs |
|----------|----------|---------------|------------|
| `.pem` key on local machine | Low — key can leak | You manage rotation | No |
| AWS Console key pair | Medium | AWS stores, you download | No |
| **SSM Session Manager** | **High — no keys at all** | **None needed** | **Yes — CloudWatch** |

**How SSM works:**

```
Your PC  ──HTTPS──▶  AWS SSM Service  ──▶  SSM Agent on EC2
                     (managed by AWS)       (pre-installed on Amazon Linux/Ubuntu)
```

- No inbound ports needed — the agent inside EC2 **calls out** to AWS over HTTPS
- Access is controlled by **IAM policies** (who can call `ssm:StartSession`)
- Every session is **logged** and auditable
- No `.pem` files to lose, rotate, or accidentally commit to git

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  AWS Cloud (ap-south-1)                         │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │  Default VPC                            │    │
│  │                                         │    │
│  │  ┌───────────────────────────────┐      │    │
│  │  │  Existing Subnet              │      │    │
│  │  │                               │      │    │
│  │  │  ┌─────────────────────┐      │      │    │
│  │  │  │  EC2 (t2.micro)     │      │      │    │
│  │  │  │  Ubuntu 24.04       │      │      │    │
│  │  │  │  IAM Role: SSM      │      │      │    │
│  │  │  │  SG: HTTP (80) only │      │      │    │
│  │  │  └─────────────────────┘      │      │    │
│  │  │                               │      │    │
│  │  └───────────────────────────────┘      │    │
│  │                                         │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  SSM Service ◄── Agent calls out (no inbound)   │
│                                                 │
└─────────────────────────────────────────────────┘
         ▲
         │ HTTPS (aws ssm start-session)
         │
    Your Local PC
```

---

## What Terraform Creates (5 Resources)

| # | Resource | What It Does |
|---|----------|-------------|
| 1 | `aws_security_group.web_sg` | Firewall — allows only HTTP (port 80) inbound. No SSH port needed. |
| 2 | `aws_iam_role.ec2_ssm_role` | IAM role that gives EC2 permission to talk to SSM service |
| 3 | `aws_iam_role_policy_attachment.ssm_policy` | Attaches AWS-managed `AmazonSSMManagedInstanceCore` policy to the role |
| 4 | `aws_iam_instance_profile.ec2_ssm_profile` | Wrapper that lets you attach the IAM role to an EC2 instance |
| 5 | `aws_instance.web_server` | The actual EC2 instance (Ubuntu 24.04, t2.micro, free-tier) |

**Data sources** (read-only lookups, not created):
- `aws_vpc.default` — finds your default VPC dynamically (no hardcoded VPC ID)
- `aws_subnets.default` — finds existing subnets in that VPC (no new subnet created)

---

## Prerequisites

### 1. Install Terraform

**On Ubuntu/WSL:**
```bash
sudo snap install terraform --classic
```

> `--classic` is required because Terraform needs filesystem and network access beyond the snap sandbox. This is safe.

**Verify:**
```bash
terraform --version
```

### 2. Install AWS CLI

**On Ubuntu/WSL:**
```bash
sudo apt update && sudo apt install awscli -y
```

**Verify:**
```bash
aws --version
```

### 3. Configure AWS Credentials

```bash
aws configure
```

| Prompt | What to enter |
|--------|---------------|
| AWS Access Key ID | Your key (starts with `AKIA...`) |
| AWS Secret Access Key | Your secret key |
| Default region name | `ap-south-1` |
| Default output format | `json` |

**Where to get your Access Key:**
1. AWS Console → search **IAM**
2. Go to **Users** → click your username
3. **Security credentials** tab → **Access keys** → **Create access key**
4. Choose **Command Line Interface (CLI)**
5. Copy both keys (you won't see the secret again)

**Verify credentials work:**
```bash
aws sts get-caller-identity
```

You should see your account ID, ARN, and user ID.

### 4. Install SSM Session Manager Plugin

This is needed to connect to EC2 from your terminal (without SSH).

**On Ubuntu/WSL:**
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
rm session-manager-plugin.deb
```

**Verify:**
```bash
session-manager-plugin
```

You should see: `The Session Manager plugin was installed successfully.`

---

## Step-by-Step Deployment

### Step 1: Initialize Terraform

```bash
cd Terraform/runEC2
terraform init
```

**What this does:** Downloads the AWS provider plugin into `.terraform/` directory.

**Expected output:** `Terraform has been successfully initialized!`

### Step 2: Preview the Plan

```bash
terraform plan
```

**What this does:** Reads `main.tf` and shows what will be created — without actually creating anything.

**Expected output:** `Plan: 5 to add, 0 to change, 0 to destroy.`

Review the plan. You should see:
- 1 security group (HTTP port 80 only)
- 1 IAM role + 1 policy attachment + 1 instance profile (for SSM)
- 1 EC2 instance (t2.micro, Ubuntu)

### Step 3: Deploy

```bash
terraform apply
```

- Type `yes` when prompted
- Wait 30–60 seconds for creation
- Note the outputs:

```
Outputs:
  instance_id        = "i-0abc123def456..."
  instance_public_ip = "13.x.x.x"
```

### Step 4: Wait 2–3 Minutes

The SSM agent inside the EC2 instance needs time to register with the SSM service after boot. If you try to connect immediately, it may fail.

### Step 5: Connect to Your Instance

```bash
aws ssm start-session --target i-0abc123def456
```

Replace `i-0abc123def456` with your actual instance ID from Step 3.

**Expected output:**
```
Starting session with SessionId: YourUser-abc123...
$
```

You're now inside your EC2 instance!

### Step 6: Switch to the Ubuntu User

SSM connects as `ssm-user` by default. Switch to `ubuntu` for a normal experience:

```bash
sudo su - ubuntu
```

Now you're at `/home/ubuntu` — same as connecting via AWS Console.

### Step 7: (Optional) Install a Web Server

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html
```

Open `http://<instance_public_ip>` in your browser — you should see "Hello from EC2!"

### Step 8: Exit the Session

```bash
exit
```

### Step 9: Clean Up (Destroy Everything)

```bash
terraform destroy
```

- Type `yes` when prompted
- Confirm all 5 resources are destroyed
- Verify in AWS Console that the instance is `terminated`

> **Always destroy when done** to avoid charges.

---

## File Structure

| File | What It Does |
|------|-------------|
| `main.tf` | All Terraform config — provider, security group, IAM role, EC2 instance |
| `README.md` | This guide |
| `.gitignore` | Tells Git to ignore state files, secrets, plugin folders |
| `.terraform/` | Auto-created by `terraform init`. Contains AWS provider plugin. Never edit. |
| `.terraform.lock.hcl` | Auto-created. Locks the exact provider version. |
| `terraform.tfstate` | Auto-created by `terraform apply`. Current state of your resources. **Never edit manually.** |
| `terraform.tfstate.backup` | Auto-created backup of previous state. |

---

## Terraform Command Flow

```
terraform init    ──→  Downloads plugins into .terraform/
                       Creates .terraform.lock.hcl
                           │
terraform plan    ──→  Reads main.tf + terraform.tfstate
                       Shows: 5 resources to create
                       (nothing actually happens)
                           │
terraform apply   ──→  Creates SG + IAM role + instance profile + EC2
                       Saves the result in terraform.tfstate
                       Prints instance ID and public IP
                           │
terraform destroy ──→  Terminates instance, deletes SG, IAM role, etc.
                       Updates terraform.tfstate
```

---

## Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `InvalidClientTokenId` | AWS credentials are wrong or expired | Run `aws configure` again with valid keys |
| `MissingInput: No subnets found` | Default VPC has no subnets | Use `data "aws_subnets"` to find existing ones (already done in our config) |
| `InvalidSubnet.Conflict` | CIDR conflicts with existing subnet | Don't create new subnets — use existing ones via data source |
| `TargetNotConnected` on SSM | SSM agent hasn't registered yet | Wait 2–3 minutes after instance launch, then retry |
| `session-manager-plugin not found` | Plugin not installed locally | Install the SSM plugin (see Prerequisites step 4) |
| `syntax error near unexpected token` | Used `<angle brackets>` in command | Remove `<` and `>` — they're placeholder markers, not part of the command |
| Instance has no public IP | Subnet doesn't auto-assign public IP | Use a subnet with `map_public_ip_on_launch = true` |

---

## SSM vs SSH — Quick Comparison

| Feature | SSH (.pem key) | SSM Session Manager |
|---------|---------------|-------------------|
| Port 22 needed? | Yes | No |
| Key management | You manage `.pem` files | None — IAM handles it |
| Audit trail | No built-in logging | CloudWatch logs every session |
| Firewall rules | Must open port 22 | No inbound ports needed |
| Works from AWS Console? | No | Yes — one-click connect |
| Works from terminal? | `ssh -i key.pem user@ip` | `aws ssm start-session --target id` |
| Security level | Low-Medium | High |
| Production recommended? | No | Yes |

---

## Key Concepts Learned

1. **Terraform data sources** — `data` blocks read existing AWS resources instead of creating new ones
2. **IAM Role + Instance Profile** — how EC2 gets permission to use AWS services (SSM in our case)
3. **SSM Session Manager** — production-standard way to access EC2 without SSH keys
4. **Security Groups** — act as firewalls; we only open port 80 (HTTP), no SSH needed
5. **`ssm-user` vs `ubuntu`** — SSM logs in as `ssm-user` by default; use `sudo su - ubuntu` to switch
