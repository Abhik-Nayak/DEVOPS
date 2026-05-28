# EC2 Instance — Terraform

Creates a single EC2 instance with a security group in AWS using Terraform.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI configured with credentials (`aws configure`)
- An AWS key pair created (if you want SSH access — see Step-by-Step Tasks below)

## Usage

```bash
terraform init      # Download AWS provider plugin
terraform plan      # Preview what will be created
terraform apply     # Create the EC2 instance + security group
terraform destroy   # Delete everything when done
```

## Configuration

Edit `main.tf` to change:

- **region** — AWS region (default: `ap-south-1`)
- **ami** — Amazon Machine Image ID (default: Amazon Linux 2023 for ap-south-1)
- **instance_type** — Instance size (default: `t2.micro`, free-tier eligible)
- **Security Group rules** — Ports allowed (default: SSH on 22, HTTP on 80)

## File Structure

| File | What it does |
|---|---|
| `main.tf` | Defines the AWS provider, security group, and EC2 instance. This is the only file you edit. |
| `.gitignore` | Tells Git which files to ignore (state files, secrets, plugin folders). |
| `.terraform/` | Auto-created by `terraform init`. Contains the downloaded AWS provider plugin. Never edit this. |
| `.terraform.lock.hcl` | Auto-created by `terraform init`. Locks the exact provider version. |
| `terraform.tfstate` | Auto-created by `terraform apply`. Stores current state of your resources. **Do not delete or edit manually.** |
| `terraform.tfstate.backup` | Auto-created backup of the previous state file. |

---

## Step-by-Step Tasks

### Task 1: Verify Prerequisites

- [ ] Confirm Terraform is installed → `terraform -version`
- [ ] Confirm AWS CLI is configured → `aws sts get-caller-identity`
- [ ] Confirm your IAM user has EC2 permissions (`AmazonEC2FullAccess` policy)

### Task 2: Create a Key Pair (for SSH access)

- [ ] Go to AWS Console → EC2 → Key Pairs → **Create key pair**
- [ ] Name it (e.g., `abhik-ec2-key`), select `.pem` format, download it
- [ ] Save the `.pem` file somewhere safe (e.g., `~/.ssh/`)
- [ ] (Optional) Add `key_name = "abhik-ec2-key"` to the `aws_instance` block in `main.tf`

### Task 3: Review the Terraform Config

- [ ] Open `main.tf` and read through each step
- [ ] Verify the **region** matches your AWS setup
- [ ] Verify the **AMI ID** is valid for your chosen region
  - Find AMIs: AWS Console → EC2 → Launch Instance → browse AMIs
- [ ] Verify `instance_type` is `t2.micro` (free-tier eligible)

### Task 4: Initialize Terraform

```bash
cd Terraform/runEC2
terraform init
```

- [ ] Run `terraform init` — downloads the AWS provider plugin
- [ ] Confirm you see: `Terraform has been successfully initialized!`

### Task 5: Plan the Deployment

```bash
terraform plan
```

- [ ] Run `terraform plan` — previews what will be created
- [ ] Confirm it shows **3 resources to add**:
  1. `aws_security_group.web_sg`
  2. `aws_instance.web_server`
  3. (Outputs: `instance_public_ip`, `instance_id`)
- [ ] Review the plan — no surprises

### Task 6: Deploy the EC2 Instance

```bash
terraform apply
```

- [ ] Run `terraform apply`
- [ ] Type `yes` when prompted
- [ ] Wait for creation (usually 30–60 seconds)
- [ ] Note the **public IP** from the output

### Task 7: Verify the Instance is Running

- [ ] Check AWS Console → EC2 → Instances → confirm instance is `running`
- [ ] Confirm the **public IP** matches the Terraform output
- [ ] Confirm the **security group** is attached with correct rules

### Task 8: Connect to the Instance (SSH)

```bash
ssh -i ~/.ssh/abhik-ec2-key.pem ec2-user@<PUBLIC_IP>
```

- [ ] Replace `<PUBLIC_IP>` with the IP from Task 6
- [ ] If using Amazon Linux, the default user is `ec2-user`
- [ ] If you get a permission error on the key: `chmod 400 ~/.ssh/abhik-ec2-key.pem`

### Task 9: (Optional) Install a Web Server

```bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html
```

- [ ] SSH into the instance (Task 8)
- [ ] Run the commands above to install Apache
- [ ] Open `http://<PUBLIC_IP>` in a browser — you should see "Hello from EC2!"

### Task 10: Clean Up (Destroy Resources)

```bash
terraform destroy
```

- [ ] Run `terraform destroy`
- [ ] Type `yes` when prompted
- [ ] Confirm all resources are destroyed (avoids ongoing charges)
- [ ] Verify in AWS Console that the instance is `terminated`

---

## Terraform Command Flow

```
terraform init  ──→  Downloads plugins into .terraform/
                     Creates .terraform.lock.hcl
                         │
terraform plan  ──→  Reads main.tf + terraform.tfstate
                     Shows: 2 resources to create
                     (nothing actually happens)
                         │
terraform apply ──→  Creates security group + EC2 instance
                     Saves the result in terraform.tfstate
                     Prints the public IP
                         │
terraform destroy ─→  Terminates instance, deletes security group
                      Updates terraform.tfstate
```

## Common Failures

| Reason | Description |
|---|---|
| Invalid AMI ID | AMI IDs are region-specific — use one valid for your chosen region |
| No key pair | Can't SSH without a key pair attached to the instance |
| Connection timeout | Security group may not allow SSH (port 22) or your IP is blocked |
| Instance limit | AWS accounts have a default vCPU limit per region |
| No public IP | Instance needs to be in a subnet with auto-assign public IP enabled |
| Permission denied | IAM user lacks `ec2:RunInstances` — needs `AmazonEC2FullAccess` policy |
| Wrong user for SSH | Amazon Linux uses `ec2-user`, Ubuntu uses `ubuntu`, Debian uses `admin` |
| Insufficient capacity | AWS ran out of `t2.micro` in that AZ — try a different AZ or instance type |
