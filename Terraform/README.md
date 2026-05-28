# Terraform — Learn Step by Step

A hands-on learning path for Terraform with AWS. Each project builds on the previous one.

---

## Prerequisites (One-Time Setup)

1. **Install Terraform** → [download](https://developer.hashicorp.com/terraform/install)
   ```bash
   terraform -version   # verify installation
   ```

2. **Install AWS CLI** → [download](https://aws.amazon.com/cli/)
   ```bash
   aws --version        # verify installation
   ```

3. **Configure AWS credentials**
   ```bash
   aws configure
   # Enter: Access Key ID, Secret Access Key, Region (ap-south-1), Output (json)
   ```

4. **Verify access**
   ```bash
   aws sts get-caller-identity   # should show your account info
   ```

---

## Learning Path

| # | Project | Folder | What You Learn |
|---|---------|--------|----------------|
| 1 | S3 Bucket | [runS3/](runS3/) | Terraform basics — provider, resource, init/plan/apply/destroy |
| 2 | EC2 Instance | [runEC2/](runEC2/) | Security groups, instance deployment, outputs, SSH access |

---

## Project 1 — S3 Bucket (`runS3/`)

**Goal:** Create your first AWS resource with Terraform.

**Key Concepts:**
- `provider` — tells Terraform which cloud to use (AWS)
- `resource` — defines what to create (S3 bucket)
- State file — how Terraform tracks what exists

**Steps:**
1. `cd runS3`
2. `terraform init` — download the AWS plugin
3. `terraform plan` — preview what will be created
4. `terraform apply` — create the S3 bucket (type `yes`)
5. Check AWS Console → S3 → verify bucket exists
6. `terraform destroy` — delete the bucket (type `yes`)

**What to change:** Edit `main.tf` to try a different bucket name or region.

---

## Project 2 — EC2 Instance (`runEC2/`)

**Goal:** Deploy a virtual server with firewall rules.

**Key Concepts:**
- `aws_security_group` — firewall rules (which ports are open)
- `aws_instance` — a virtual server (EC2)
- `output` — print useful info after deployment (like the public IP)
- AMI — the operating system image for the server

**Steps:**
1. `cd runEC2`
2. Create a key pair in AWS Console (EC2 → Key Pairs) for SSH access
3. `terraform init` — download the AWS plugin
4. `terraform plan` — preview: security group + EC2 instance
5. `terraform apply` — deploy the server (type `yes`)
6. Copy the public IP from the output
7. `ssh -i ~/.ssh/your-key.pem ec2-user@<PUBLIC_IP>` — connect to the server
8. (Optional) Install a web server:
   ```bash
   sudo yum install -y httpd
   sudo systemctl start httpd
   echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html
   ```
9. Open `http://<PUBLIC_IP>` in a browser
10. `terraform destroy` — delete everything (type `yes`)

**What to change:** Edit `main.tf` to try a different instance type, AMI, or add more ports.

---

## Terraform Core Commands

| Command | What It Does |
|---------|-------------|
| `terraform init` | Downloads provider plugins, sets up working directory |
| `terraform plan` | Shows what will be created/changed/destroyed (dry run) |
| `terraform apply` | Actually creates/changes resources in AWS |
| `terraform destroy` | Deletes all resources managed by this config |
| `terraform fmt` | Auto-formats your `.tf` files |
| `terraform validate` | Checks your config for syntax errors |
| `terraform show` | Shows the current state |

## Terraform File Types

| File | Purpose |
|------|---------|
| `*.tf` | Your configuration files (what to create) |
| `*.tfvars` | Variable values (often contains secrets — never commit) |
| `.terraform/` | Downloaded plugins (auto-created by `init`) |
| `.terraform.lock.hcl` | Locks plugin versions (auto-created by `init`) |
| `terraform.tfstate` | Current state of resources (auto-created by `apply`) |

## Common Troubleshooting

| Problem | Fix |
|---------|-----|
| `No credentials` | Run `aws configure` and enter valid keys |
| `Access Denied` | Your IAM user needs the right permissions |
| `Resource already exists` | Someone created it outside Terraform — import or rename |
| `State lock` | Another `terraform apply` is running — wait or force-unlock |
| `Plugin not found` | Run `terraform init` again |

---

## Interview Questions — S3 (Project 1)

### Basics

**Q1. What is Amazon S3?**
S3 (Simple Storage Service) is an object storage service that stores data as objects in buckets. It provides unlimited storage with 99.999999999% (11 nines) durability.

**Q2. What is an S3 bucket and what are the naming rules?**
A bucket is a container for objects in S3. Rules: globally unique name across all AWS accounts, 3–63 characters, lowercase only, no underscores, must start/end with a letter or number.

**Q3. What does the `provider` block do in Terraform?**
It tells Terraform which cloud platform to use and configures the connection. For AWS, it specifies the region and uses credentials from `aws configure` or environment variables.

**Q4. What does `terraform init` actually do behind the scenes?**
It downloads the provider plugins (e.g., AWS) into the `.terraform/` directory, creates `.terraform.lock.hcl` to lock provider versions, and initializes the backend for state storage.

**Q5. What is the difference between `terraform plan` and `terraform apply`?**
`plan` is a dry run — it reads the config and state file, then shows what will be created, changed, or destroyed without making any changes. `apply` actually executes those changes in AWS and updates the state file.

**Q6. What is `terraform.tfstate` and why is it important?**
It's a JSON file that maps your Terraform config to real AWS resources. Terraform uses it to know what exists, what to update, and what to destroy. Losing it means Terraform loses track of your infrastructure.

**Q7. Why should you never commit `terraform.tfstate` to Git?**
It can contain sensitive data (passwords, keys, IPs). It also causes merge conflicts in teams. Instead, use remote backends like S3 + DynamoDB for shared state.

**Q8. What happens if you delete the state file and run `terraform apply` again?**
Terraform thinks no resources exist and tries to create everything again. This will fail if resources (like an S3 bucket with the same name) already exist in AWS.

**Q9. What is the purpose of `.terraform.lock.hcl`?**
It locks the exact version of provider plugins so that every team member and CI/CD pipeline uses the same version. Similar to `package-lock.json` in Node.js.

**Q10. S3 bucket names are globally unique — what does that mean?**
No two AWS accounts anywhere in the world can have a bucket with the same name. If `my-bucket-123` exists in someone else's account, you cannot use that name.

### Scenario-Based

**Q11. You run `terraform apply` and get "BucketAlreadyExists". What do you do?**
Either change the bucket name in `main.tf` to something unique, or if the bucket is yours but was created outside Terraform, use `terraform import` to bring it under Terraform management.

**Q12. How would you enable versioning on this S3 bucket using Terraform?**
Add an `aws_s3_bucket_versioning` resource block referencing the bucket, with `versioning_configuration { status = "Enabled" }`.

**Q13. How would you make this bucket private and block all public access?**
Add an `aws_s3_bucket_public_access_block` resource with `block_public_acls = true`, `block_public_policy = true`, `ignore_public_acls = true`, `restrict_public_buckets = true`.

---

## Interview Questions — EC2 (Project 2)

### Basics

**Q14. What is an EC2 instance?**
EC2 (Elastic Compute Cloud) is a virtual server in AWS. You choose the OS (AMI), hardware (instance type), and networking — then AWS provisions it in seconds.

**Q15. What is an AMI?**
AMI (Amazon Machine Image) is a template containing the OS and pre-installed software. Example: `ami-0f58b397bc5c1f2e8` is Amazon Linux 2023 for ap-south-1. AMI IDs are region-specific.

**Q16. What is `t2.micro` and why is it used here?**
It's an instance type with 1 vCPU and 1 GB RAM. It's part of the AWS Free Tier (750 hours/month for 12 months), making it ideal for learning and testing.

**Q17. What is a Security Group in AWS?**
A Security Group acts as a virtual firewall for EC2 instances. It controls inbound (ingress) and outbound (egress) traffic using rules based on port, protocol, and source/destination IP.

**Q18. Explain the Security Group rules in this config.**
- **Ingress rule 1:** Allows SSH (port 22) from anywhere (`0.0.0.0/0`) — for remote login.
- **Ingress rule 2:** Allows HTTP (port 80) from anywhere — for web traffic.
- **Egress rule:** Allows all outbound traffic (protocol `-1` means all protocols) — so the instance can reach the internet.

**Q19. What does `0.0.0.0/0` mean in a CIDR block?**
It means "all IP addresses" — the rule applies to traffic from/to the entire internet. In production, you'd restrict SSH to specific IPs for security.

**Q20. What does protocol `-1` mean in the egress rule?**
It means "all protocols" (TCP, UDP, ICMP, etc.). Combined with ports 0–0, it allows all outbound traffic.

**Q21. What is the `output` block used for?**
It prints values after `terraform apply` completes. Here it shows the public IP and instance ID, so you can SSH into the server or find it in the AWS Console without logging in.

**Q22. How does `vpc_security_group_ids` work in the EC2 resource?**
It attaches one or more Security Groups to the instance using their IDs. The syntax `[aws_security_group.web_sg.id]` creates an implicit dependency — Terraform knows to create the SG before the instance.

**Q23. What is an implicit dependency in Terraform?**
When one resource references another (like EC2 referencing the SG's ID), Terraform automatically determines the creation order. No explicit `depends_on` is needed.

### Scenario-Based

**Q24. You deployed the EC2 instance but can't SSH into it. What could be wrong?**
Possible causes: (1) No key pair attached — the config is missing `key_name`. (2) Security Group doesn't allow port 22 from your IP. (3) Instance is in a private subnet with no public IP. (4) Local firewall or VPN blocking outbound SSH.

**Q25. The config allows SSH from `0.0.0.0/0`. Is this safe for production?**
No. It allows SSH from any IP on the internet, making it vulnerable to brute-force attacks. In production, restrict to your office/VPN IP like `cidr_blocks = ["203.0.113.50/32"]`.

**Q26. How would you add HTTPS (port 443) to this Security Group?**
Add another `ingress` block with `from_port = 443`, `to_port = 443`, `protocol = "tcp"`, and appropriate `cidr_blocks`.

**Q27. What happens if you change the AMI ID and run `terraform apply`?**
Terraform will **destroy** the existing instance and create a new one with the new AMI — this is called a "force replacement." Any data on the old instance is lost.

**Q28. How would you avoid hardcoding the AMI ID?**
Use a `data` source: `data "aws_ami" "latest" { most_recent = true, owners = ["amazon"], filter { name = "name", values = ["al2023-ami-*"] } }` — this always fetches the latest AMI.

### Cross-Project / General Terraform

**Q29. What is the difference between `terraform destroy` and manually deleting resources in the AWS Console?**
`terraform destroy` deletes resources AND updates the state file. Manual deletion leaves the state file out of sync — Terraform will error on the next `apply` because it thinks the resource still exists.

**Q30. Can you run `terraform apply` for S3 and EC2 at the same time?**
Not from the same directory — each directory has its own state. You'd run them from `runS3/` and `runEC2/` separately. To manage them together, use Terraform modules or workspaces.

**Q31. What is the difference between `resource` and `data` in Terraform?**
`resource` creates and manages infrastructure. `data` reads information about existing infrastructure that Terraform doesn't manage (e.g., looking up the latest AMI or default VPC).

**Q32. What are Terraform variables and why aren't they used in these configs?**
Variables (`variable` blocks) let you parameterize configs instead of hardcoding values. These configs hardcode region, bucket name, AMI, etc. for simplicity. In real projects, you'd use variables with `.tfvars` files.

**Q33. What is `terraform fmt` and when should you use it?**
It auto-formats `.tf` files to follow HashiCorp's style conventions (indentation, alignment). Run it before committing code to keep configs consistent across the team.

**Q34. Explain the Terraform lifecycle: Write → Init → Plan → Apply → Destroy.**
1. **Write** — define infrastructure in `.tf` files.
2. **Init** — download providers, set up backend.
3. **Plan** — preview changes (compare config vs. state).
4. **Apply** — execute changes, update state.
5. **Destroy** — tear down all managed resources.

**Q35. How would you manage Terraform state in a team environment?**
Use a remote backend like S3 with DynamoDB for state locking. This ensures only one person can modify state at a time and the state file is shared, versioned, and encrypted.

---

## What's Next?

Future projects to add:

- **Project 3** — VPC + Subnets (networking fundamentals)
- **Project 4** — RDS Database (managed databases)
- **Project 5** — Load Balancer + Auto Scaling (high availability)
- **Project 6** — Terraform Modules (reusable infrastructure)
