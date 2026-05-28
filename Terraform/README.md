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

## Terraform Interview Questions

### Basics

**Q1. What is Terraform?**
Terraform is an open-source Infrastructure as Code (IaC) tool by HashiCorp. You write declarative config files (`.tf`) to define infrastructure, and Terraform creates, updates, and deletes resources across any cloud provider (AWS, Azure, GCP, etc.).

**Q2. What is Infrastructure as Code (IaC) and why does it matter?**
IaC means managing infrastructure through code files instead of manual clicks in a console. Benefits: version control, repeatability, consistency across environments, peer review of changes, and automated deployments.

**Q3. What language does Terraform use?**
HCL (HashiCorp Configuration Language). It's a declarative language — you describe the desired end state, not the steps to get there. Terraform also supports JSON as an alternative syntax.

**Q4. What is the difference between declarative and imperative IaC?**
- **Declarative (Terraform):** You say "I want 3 servers" — Terraform figures out what to create/delete to reach that state.
- **Imperative (scripts/Ansible):** You say "Create server 1, then server 2, then server 3" — you define every step.

**Q5. What is a Terraform Provider?**
A provider is a plugin that lets Terraform talk to a specific platform (AWS, Azure, GCP, Kubernetes, etc.). Each provider exposes resources and data sources for that platform. Defined in the `provider` block.

**Q6. What is a Terraform Resource?**
A resource is a single piece of infrastructure (EC2 instance, S3 bucket, VPC, etc.). It's defined with `resource "type" "name" { ... }`. Terraform creates, updates, and destroys resources to match your config.

**Q7. What is Terraform State?**
State is a JSON file (`terraform.tfstate`) that maps your config to real-world resources. Terraform uses it to know what exists, detect drift, and determine what changes are needed on the next `apply`.

**Q8. Explain the Terraform workflow: init → plan → apply → destroy.**
1. `terraform init` — downloads provider plugins, initializes backend.
2. `terraform plan` — compares config vs. state, shows what will change (dry run).
3. `terraform apply` — executes the changes, updates state.
4. `terraform destroy` — deletes all managed resources, updates state.

**Q9. What does `terraform init` do?**
Downloads provider plugins into `.terraform/`, creates `.terraform.lock.hcl` (version lock), initializes the configured backend for state storage, and downloads any referenced modules.

**Q10. What is the difference between `terraform plan` and `terraform apply`?**
`plan` is read-only — it shows what will be created/changed/destroyed without touching anything. `apply` actually performs those actions and writes the result to the state file.

### State Management

**Q11. Why is the state file important?**
Without state, Terraform can't know what resources it manages. State maps config to real resources, tracks metadata (IDs, IPs), detects drift, and determines the correct order of operations.

**Q12. Why should you never commit `terraform.tfstate` to Git?**
It contains sensitive data (passwords, keys, IPs, ARNs). It also causes merge conflicts in teams. Use a remote backend (S3 + DynamoDB, Terraform Cloud) instead.

**Q13. What is a remote backend?**
A remote backend stores state outside your local machine — e.g., in S3, Azure Blob, GCS, or Terraform Cloud. Benefits: shared access for teams, state locking to prevent concurrent modifications, encryption, and versioning.

**Q14. What is state locking and why is it needed?**
State locking prevents two people from running `terraform apply` at the same time, which could corrupt the state. DynamoDB (for S3 backend) or Terraform Cloud handles this automatically.

**Q15. What happens if you lose or delete the state file?**
Terraform forgets all resources it created. Running `apply` again tries to create everything from scratch, which fails if resources already exist. You'd need `terraform import` to recover.

**Q16. What is `terraform import`?**
It brings existing resources (created manually or by another tool) under Terraform management by adding them to the state file. Example: `terraform import aws_s3_bucket.my_bucket my-bucket-name`.

**Q17. What is state drift?**
Drift happens when real infrastructure changes outside Terraform (someone manually edits a resource in the console). `terraform plan` detects drift by comparing state to actual cloud resources.

### Variables and Outputs

**Q18. What are the types of variables in Terraform?**
- **Input variables** (`variable`) — parameters for your config. Defined with types like `string`, `number`, `bool`, `list`, `map`, `object`.
- **Output variables** (`output`) — values displayed after apply (e.g., public IP).
- **Local variables** (`locals`) — computed values reused within a module.

**Q19. What are the ways to pass values to input variables? (Precedence order)**
1. Command line: `-var "name=value"`
2. Variable file: `-var-file="prod.tfvars"`
3. Auto-loaded files: `terraform.tfvars` or `*.auto.tfvars`
4. Environment variables: `TF_VAR_name=value`
5. Default value in the `variable` block.
6. Interactive prompt (if no default and no value provided).

**Q20. What is the difference between `variable`, `locals`, and `output`?**
- `variable` — input from outside the module (user provides value).
- `locals` — intermediate computed values used inside the module (not exposed).
- `output` — values exported from the module (displayed or consumed by other modules).

**Q21. How do you mark a variable as sensitive?**
Add `sensitive = true` in the variable block. Terraform will hide the value in plan/apply output, but it still exists in state. Example: `variable "db_password" { type = string, sensitive = true }`.

### Modules

**Q22. What is a Terraform Module?**
A module is a reusable container of `.tf` files. Every Terraform directory is a module (the root module). Child modules are called with `module "name" { source = "./path" }`. They enable DRY, reusable infrastructure.

**Q23. What is the difference between a root module and a child module?**
- **Root module** — the directory where you run `terraform apply`. It's the entry point.
- **Child module** — a module called from the root module using `module` block. Can be local paths, Git repos, or Terraform Registry.

**Q24. How do you pass data between modules?**
Parent passes data to child via input variables. Child exposes data to parent via outputs. Example: `module.vpc.vpc_id` reads the `vpc_id` output from the `vpc` module.

### Dependencies and Lifecycle

**Q25. What is an implicit dependency?**
When Resource A references Resource B's attribute (e.g., `security_group_id = aws_security_group.sg.id`), Terraform automatically knows to create B before A. No extra config needed.

**Q26. What is `depends_on` and when do you use it?**
`depends_on` creates an explicit dependency when Terraform can't detect it automatically. Example: an EC2 instance that needs an IAM role policy attached before launch, but doesn't reference the policy directly.

**Q27. What is a `lifecycle` block?**
It controls how Terraform handles resource changes:
- `create_before_destroy` — create the new resource before deleting the old one (zero downtime).
- `prevent_destroy` — block `terraform destroy` on this resource (safety net for databases).
- `ignore_changes` — ignore changes to specific attributes (e.g., tags modified outside Terraform).

**Q28. What is a "tainted" resource?**
A tainted resource is marked for forced recreation on the next `apply`. Used when a resource is in a bad state. Command: `terraform taint aws_instance.web` (deprecated in favor of `terraform apply -replace`).

### Advanced Concepts

**Q29. What are `data` sources?**
Data sources read information about existing infrastructure that Terraform doesn't manage. Example: `data "aws_ami" "latest" { ... }` fetches the latest AMI ID. They're read-only — Terraform never modifies data sources.

**Q30. What is the difference between `count` and `for_each`?**
- `count` — creates N copies of a resource by index (`count = 3` → `resource[0]`, `resource[1]`, `resource[2]`). Removing an item shifts all indexes.
- `for_each` — creates one copy per item in a map/set (`for_each = toset(["dev","prod"])`). Removing an item only affects that key. **Prefer `for_each`** — it's safer.

**Q31. What are Terraform Workspaces?**
Workspaces let you manage multiple state files from the same config (e.g., dev, staging, prod). Each workspace has its own state. Access the workspace name with `terraform.workspace`. Good for small setups; for large ones, use separate directories or modules.

**Q32. What is a Provisioner and why should you avoid it?**
Provisioners run scripts on a resource after creation (e.g., `remote-exec` to install software via SSH). They're a last resort because they break the declarative model, don't update state, and can't be planned. Use cloud-init, user_data, or config management tools (Ansible) instead.

**Q33. What is `terraform refresh`?**
It reads the real state of all resources from the cloud and updates the state file. This detects drift. In Terraform 0.15+ it's automatically part of `plan` and `apply`. Rarely run manually.

**Q34. How does Terraform handle secrets?**
Terraform itself doesn't encrypt secrets. Best practices: (1) Mark variables as `sensitive`. (2) Use remote state with encryption (S3 + SSE). (3) Never commit `.tfvars` with secrets to Git. (4) Integrate with HashiCorp Vault or AWS Secrets Manager via data sources.

**Q35. What is `terraform graph`?**
It outputs a visual dependency graph of resources in DOT format. Useful for understanding the order Terraform will create/destroy resources. Pipe to Graphviz to render: `terraform graph | dot -Tpng > graph.png`.

### Scenario-Based

**Q36. You run `terraform apply` and it fails halfway. What happens?**
Terraform applies changes one resource at a time. Successfully created resources are saved to state. Failed resources are not. On the next `apply`, Terraform picks up where it left off — it only creates/updates what's still missing.

**Q37. Someone manually changed a Security Group in the AWS Console. How do you detect and fix it?**
Run `terraform plan` — it compares state to the real cloud and shows drift. If the manual change should be reverted, run `terraform apply`. If the manual change should be kept, update your `.tf` config to match, then run `terraform apply` (no changes shown = in sync).

**Q38. How do you move a resource from one state file to another?**
Use `terraform state mv` to move within the same state, or `terraform state rm` + `terraform import` to move between separate state files. In Terraform 1.1+ you can use the `moved` block in config.

**Q39. Your team of 5 developers all use Terraform. How do you prevent conflicts?**
(1) Use a remote backend (S3 + DynamoDB) for shared state with locking. (2) Use CI/CD pipelines (GitHub Actions, GitLab CI) so only the pipeline runs `apply`. (3) Review `plan` output in pull requests. (4) Use branch-based workflows — never apply from local machines.

**Q40. How would you manage infrastructure across multiple AWS accounts (dev, staging, prod)?**
Options: (1) Use separate provider aliases with different credentials per account. (2) Use Terraform Workspaces with different variable files. (3) Use separate directories per environment with shared modules. (4) Use Terragrunt for DRY multi-environment configs. Option 3 or 4 is most common in production.

---

## What's Next?

Future projects to add:

- **Project 3** — VPC + Subnets (networking fundamentals)
- **Project 4** — RDS Database (managed databases)
- **Project 5** — Load Balancer + Auto Scaling (high availability)
- **Project 6** — Terraform Modules (reusable infrastructure)
