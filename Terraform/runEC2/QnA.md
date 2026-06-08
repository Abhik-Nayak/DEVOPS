# EC2 + SSM — Questions & Answers

Real-world questions and answers while learning Terraform + AWS, answered from a senior DevOps/Cloud engineer perspective.

---

## Q1: If I create infra with SSM, how do my 5 team members connect to the same instance from their devices?

### Short Answer

They don't need keys. They need **IAM permissions**. You control access through IAM policies — not by sharing `.pem` files.

### How It Works in a Real Team

When you set up SSM, access to the EC2 instance is controlled by **who has permission to call `ssm:StartSession`** in AWS. So the question becomes: "How do I give my 5 team members the right IAM permissions?"

There are 3 levels of maturity:

---

### Level 1: IAM Users (Small Team / Learning)

Each team member gets their own IAM user with an IAM policy attached.

```
Team Member → Their own IAM User → IAM Policy → ssm:StartSession → EC2 Instance
```

**Steps:**
1. Create an IAM user for each team member in AWS Console (IAM → Users → Create User)
2. Attach a policy that allows SSM access
3. Give each member their own Access Key + Secret Key
4. They run `aws configure` on their device with their own keys
5. They connect with: `aws ssm start-session --target i-xxxxx`

**Example IAM Policy (attach to each user):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:StartSession",
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": [
        "arn:aws:ec2:ap-south-1:ACCOUNT_ID:instance/i-0abc123def456"
      ]
    }
  ]
}
```

**Pros:** Simple, works fast.
**Cons:** Doesn't scale. Managing 5 users is fine, 50 is painful.

---

### Level 2: IAM Groups (Medium Team / Startup)

Instead of attaching policies to each user individually, create a **group**.

```
Team Members → IAM Group "devops-team" → IAM Policy → SSM Access
```

**Steps:**
1. Create an IAM Group called `devops-team`
2. Attach the SSM policy to the group
3. Add all 5 members to the group
4. New joiners? Just add them to the group. Someone leaves? Remove them.

**Why this is better:** One policy change applies to everyone. You don't touch individual users.

---

### Level 3: AWS IAM Identity Center (SSO) — Production / Enterprise

This is what companies actually use. No long-lived Access Keys at all.

```
Team Member → SSO Login (company email) → Temporary credentials → SSM Access
```

**How it works:**
1. Set up AWS IAM Identity Center (formerly AWS SSO)
2. Connect it to your company's identity provider (Google Workspace, Okta, Azure AD, etc.)
3. Create permission sets (e.g., "DevOps-SSM-Access")
4. Assign permission sets to groups
5. Team members log in via a portal URL → get temporary credentials → connect

**Why production teams use this:**
- No long-lived Access Keys (keys expire every 1–12 hours)
- Team members use their company email to log in
- Centralized: disable someone's company email → they lose AWS access instantly
- Audit: you can see exactly who accessed what and when

---

### What Happens When Someone Leaves the Team?

| Approach | What you do |
|----------|------------|
| SSH with `.pem` files | Pray they deleted the key. Rotate keys on every server. Hope they didn't copy it. |
| IAM Users | Delete their IAM user or remove from group. Instant revocation. |
| SSO | Disable their company email. They lose all AWS access automatically. |

This is the **real reason** SSM is better than SSH keys — it's not just about convenience, it's about **access control and revocation**.

---

### Fine-Grained Access: Who Can Access Which Instance?

In a real team, not everyone should access every server. SSM lets you control this with IAM policies:

**Dev team — can only access dev instances:**
```json
{
  "Effect": "Allow",
  "Action": "ssm:StartSession",
  "Resource": "arn:aws:ec2:ap-south-1:*:instance/*",
  "Condition": {
    "StringEquals": {
      "ssm:resourceTag/Environment": "dev"
    }
  }
}
```

**Ops team — can access prod instances:**
```json
{
  "Condition": {
    "StringEquals": {
      "ssm:resourceTag/Environment": "prod"
    }
  }
}
```

This means you control access by **tagging your EC2 instances** (`Environment: dev`, `Environment: prod`) and writing policies against those tags. No key distribution, no VPN configs, no bastion hosts.

---

### What a Senior DevOps Engineer Would Set Up

```
┌──────────────────────────────────────────────────────┐
│  Identity Provider (Google/Okta/Azure AD)             │
│  - All team members have company accounts             │
└──────────────┬───────────────────────────────────────┘
               │ SSO
               ▼
┌──────────────────────────────────────────────────────┐
│  AWS IAM Identity Center                              │
│  - Permission Set: "DevOps-SSM-Access"                │
│  - Permission Set: "Dev-ReadOnly"                     │
│  - Mapped to groups from identity provider            │
└──────────────┬───────────────────────────────────────┘
               │ Temporary credentials (auto-expire)
               ▼
┌──────────────────────────────────────────────────────┐
│  AWS Account                                          │
│                                                       │
│  EC2 Instances (tagged by environment)                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐              │
│  │ dev-app │  │ stg-app │  │ prd-app │              │
│  │ Tag:dev │  │ Tag:stg │  │ Tag:prd │              │
│  └─────────┘  └─────────┘  └─────────┘              │
│                                                       │
│  IAM Policy: Dev team → only dev/stg tagged instances │
│  IAM Policy: Ops team → all instances                 │
│  IAM Policy: Intern   → only dev tagged instances     │
└──────────────────────────────────────────────────────┘
```

---

### Summary

| Question | Answer |
|----------|--------|
| Do team members need `.pem` files? | No |
| Do they need SSH? | No |
| What do they need? | IAM permissions to call `ssm:StartSession` |
| How to give access? | IAM Users (simple) → IAM Groups (better) → SSO (production) |
| How to revoke access? | Delete user / remove from group / disable SSO account |
| How to limit access? | Tag instances + IAM policies with conditions |
| What do companies actually use? | SSO + tag-based access + CloudWatch session logging |

---

### Your Action Items (to practice)

- [ ] Create a second IAM user in AWS Console
- [ ] Attach an SSM policy to that user
- [ ] Configure AWS CLI with the second user's keys (use `aws configure --profile teammate`)
- [ ] Try connecting: `aws ssm start-session --target i-xxxxx --profile teammate`
- [ ] Now remove the SSM policy from that user and try again — it should fail
- [ ] This proves access control is working through IAM, not keys
