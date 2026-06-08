# Day 01 — Terraform State + First EC2

> **Deliverable:** An EC2 instance running with S3 remote backend + DynamoDB state locking configured.

---

## What You're Building

A single EC2 instance (t3.micro) with a security group allowing SSH (port 22) and HTTP (port 80). You'll start with local state, then migrate to S3 remote state with DynamoDB locking — the standard production setup.

By the end of today, you should be able to run `terraform plan`, `terraform apply`, and `terraform destroy` confidently, and explain what happens at each step.

---

## Before You Start

1. **Install Terraform** — download from terraform.io, add to PATH, verify with `terraform -version`
2. **Configure AWS CLI** — run `aws configure`, set your Access Key, Secret Key, region (`ap-south-1` or `us-east-1`)
3. **Verify access** — run `aws sts get-caller-identity` — you should see your account ID

---

## Step-by-Step: What to Do

### Part 1 — Local State (do this first)

1. Create a file called `main.tf`
2. Define the **provider block** — tell Terraform you're using AWS and which region
3. Define an **aws_security_group** resource:
   - Allow inbound on port 22 (SSH) from your IP (or 0.0.0.0/0 for now)
   - Allow inbound on port 80 (HTTP) from anywhere
   - Allow all outbound traffic
4. Define an **aws_instance** resource:
   - Use AMI for Amazon Linux 2 in your region (find it in the EC2 console → Launch Instance → copy the AMI ID)
   - Instance type: `t3.micro` (free tier eligible with `t2.micro`, but `t3.micro` is what you'll use in real jobs)
   - Attach your security group
   - Add a `Name` tag
5. Run these commands in order:
   ```
   terraform init
   terraform plan
   terraform apply
   ```
6. Go to AWS Console → EC2 — verify your instance is running
7. Notice the `terraform.tfstate` file created locally — open it, read it, understand it

### Part 2 — Remote State with S3 + DynamoDB

8. **Manually create** (via AWS Console or CLI) an S3 bucket for state:
   - Bucket name: something unique like `<your-name>-terraform-state`
   - Enable versioning on the bucket
9. **Manually create** a DynamoDB table for state locking:
   - Table name: `terraform-locks`
   - Partition key: `LockID` (type: String)
10. Add a **backend "s3"** block inside your `terraform` block in `main.tf`:
    - Set `bucket`, `key` (path inside the bucket, e.g. `day-01/terraform.tfstate`), `region`
    - Set `dynamodb_table` to your lock table name
    - Set `encrypt = true`
11. Run `terraform init` again — Terraform will ask if you want to migrate state to S3. Say yes.
12. Verify: the local `terraform.tfstate` should now be nearly empty, and your state lives in S3

### Part 3 — Lifecycle Commands

13. Make a change — add or modify a tag on your EC2 instance
14. Run `terraform plan` — read the diff carefully. Understand `+`, `-`, `~` symbols
15. Run `terraform apply` — confirm the change
16. Run `terraform destroy` — tear everything down (keep the S3 bucket and DynamoDB table for future days)

---

## Key Concepts to Focus On

### Understand deeply — don't just copy-paste

| Concept | Why It Matters |
|---------|---------------|
| **State file** | Terraform's memory. Without it, Terraform doesn't know what exists. Open `terraform.tfstate` and read the JSON — know what's inside. |
| **Plan → Apply → Destroy** | This is the lifecycle. `plan` is a dry run. `apply` makes it real. Never skip `plan`. |
| **Remote state** | Teams can't share a local file. S3 stores state centrally. This is non-negotiable in production. |
| **State locking** | Two people running `apply` at once = corrupted state. DynamoDB prevents this with a lock. |
| **Provider vs Resource** | Provider = the plugin (AWS, GCP, Azure). Resource = the thing you're creating (EC2, S3, etc). |
| **Idempotency** | Running `apply` twice with no changes = no changes. Terraform only acts on drift. |

### Common mistakes to watch for

- Forgetting to run `terraform init` after adding a backend block
- Using a DynamoDB partition key name other than `LockID` (it must be exactly `LockID`)
- Hardcoding AMI IDs that don't exist in your region
- Not enabling versioning on the S3 state bucket (you'll want rollback ability)
- Leaving EC2 running overnight — always `terraform destroy` at end of day

---

## Files You Should Have by End of Day

```
day-01/
└── main.tf          # provider + backend + security group + EC2 instance
```

That's it. One file. Keep it simple on Day 01. Variables and outputs come tomorrow.

---

## Interview Prep

### Questions you should be able to answer after today

**Q1: What is Terraform state and why is it important?**
> Think about: what happens if you delete the state file? What happens if two people have different state files? Why is it JSON and not just "re-scan AWS"?

**Q2: What happens if two engineers run `terraform apply` at the same time?**
> Think about: state locking, DynamoDB, what error message they'd see, what happens without locking.

**Q3: Why use S3 + DynamoDB for remote state instead of just committing `terraform.tfstate` to Git?**
> Think about: secrets in state (RDS passwords end up in state!), merge conflicts in JSON, locking, team access.

**Q4: What's the difference between `terraform plan` and `terraform apply`?**
> Think about: is `plan` just a preview? Can `plan` output differ from what `apply` actually does? (Yes — if someone changes infra between plan and apply.)

**Q5: If you run `terraform apply` and then immediately run it again with no changes, what happens?**
> Think about: idempotency, "No changes. Your infrastructure matches the configuration."

**Q6: What is the difference between `terraform destroy` and just deleting the `.tf` files?**
> Think about: orphaned resources, state tracking, cloud bill surprises.

### How to practice these

Don't memorize answers. Instead:
1. Actually try each scenario (delete state file, run apply twice, etc.)
2. Write your answer in 2–3 sentences from memory
3. Compare with what actually happened

---

## Stretch Goals (if you finish early)

- SSH into your EC2 instance and run `curl http://169.254.169.254/latest/meta-data/` to explore instance metadata
- Try running `terraform plan` from a second terminal simultaneously and watch DynamoDB locking kick in
- Read the actual `terraform.tfstate` JSON line by line — find your security group ID, instance ID, and AMI in it
- Break something on purpose: manually delete the EC2 from the console, then run `terraform plan` — observe what Terraform wants to do

---

## Docs to Read Today

- [Terraform AWS Provider — aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Terraform AWS Provider — aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [Terraform Backend — S3](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
