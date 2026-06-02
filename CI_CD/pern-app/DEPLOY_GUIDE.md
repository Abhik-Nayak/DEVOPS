# PERN App — Deploy to AWS EC2

## What was created

| File | Purpose |
|------|---------|
| `docker-compose.prod.yml` | Production Docker config (builds optimized images, exposes only port 80) |
| `deploy.sh` | Script that runs on EC2 to pull code and restart containers |
| `.github/workflows/deploy.yml` | GitHub Actions pipeline — auto-deploys on every push to main |

---

## Step-by-Step Setup

### STEP 1: Push code to GitHub

```bash
cd pern-app
git init
git add .
git commit -m "Add deployment files"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/pern-app.git
git push -u origin main
```

**✓ Check:** Go to github.com — your files are visible.

---

### STEP 2: Create EC2 instance

1. Go to **AWS Console → EC2 → Launch Instance**
2. Settings:
   - Name: `pern-app-server`
   - AMI: **Ubuntu 22.04 LTS**
   - Instance type: **t2.micro** (free tier)
   - Key pair: Create new → download `.pem` file
   - Security Group: Allow these ports:
     - **22** (SSH)
     - **80** (HTTP)
3. Click **Launch Instance**
4. Copy the **Public IPv4 address**

**✓ Check:** Instance state shows "Running" in AWS console.

---

### STEP 3: Setup EC2 server

SSH into your EC2:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

Run these commands inside EC2:
```bash
# Install Docker
sudo apt update && sudo apt install -y docker.io docker-compose git

# Allow ubuntu user to run Docker
sudo usermod -aG docker ubuntu

# Log out and back in (required!)
exit
```

SSH back in:
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

Clone your repo:
```bash
git clone https://github.com/YOUR_USERNAME/pern-app.git ~/pern-app
```

Test that it works:
```bash
cd ~/pern-app
docker-compose -f docker-compose.prod.yml up -d --build
```

**✓ Check:** Open `http://YOUR_EC2_IP` in browser — you see your Task Manager app!

---

### STEP 4: Add GitHub Secrets

Go to **GitHub → your repo → Settings → Secrets and variables → Actions → New repository secret**

Add these 3 secrets:

| Secret Name | Value |
|-------------|-------|
| `EC2_HOST` | Your EC2 public IP (e.g., `54.123.45.67`) |
| `EC2_USER` | `ubuntu` |
| `EC2_SSH_KEY` | Full contents of your `.pem` file (open in notepad, copy everything) |

**✓ Check:** You see 3 secrets listed in GitHub settings.

---

### STEP 5: Deploy automatically

Now every time you push to main, it auto-deploys!

```bash
# Make a change locally
git add .
git commit -m "my update"
git push origin main
```

**✓ Check:** Go to GitHub → Actions tab → you see a green checkmark. Open `http://YOUR_EC2_IP` — changes are live!

---

## Useful Commands (run on EC2)

```bash
# View running containers
docker ps

# View logs
docker-compose -f docker-compose.prod.yml logs

# View backend logs only
docker-compose -f docker-compose.prod.yml logs backend

# Restart everything
docker-compose -f docker-compose.prod.yml restart

# Stop everything
docker-compose -f docker-compose.prod.yml down

# Rebuild from scratch (if something breaks)
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d --build
```
