# 🔧 Git Setup Guide - Submodules Strategy

## 📋 Overview

Repository structure dengan 3 repositories:
1. **dashboard** (super repo) - Main repository dengan documentation
2. **backend-dashboard-python** (submodule) - FastAPI backend
3. **dashboard-message-center** (submodule) - Next.js frontend

---

## 🎯 Repository Structure

```
GitHub Account: nabilhatami86
├── dashboard                         (Super Repo)
│   ├── backend-dashboard-python/     (Submodule → backend repo)
│   ├── dashboard-message-center/     (Submodule → frontend repo)
│   ├── README.md                      (Main documentation)
│   ├── SETUP_SUMMARY.md
│   └── ... (other documentation files)
│
├── backend-dashboard-python          (Backend Repo)
│   ├── app/
│   ├── requirements.txt
│   ├── .env.example
│   └── ...
│
└── dashboard-message-center          (Frontend Repo)
    ├── app/
    ├── components/
    ├── package.json
    └── ...
```

---

## 📝 Step-by-Step Setup

### Step 1: Create GitHub Repositories

Create **3 new repositories** on GitHub:

1. **Dashboard Super Repo**
   - Name: `dashboard`
   - Description: WhatsApp Multi-Channel Customer Service Dashboard
   - Visibility: Private/Public
   - ❌ Don't initialize with README (we have our own)

2. **Backend Repo**
   - Name: `backend-dashboard-python`
   - Description: FastAPI backend with WhatsApp webhook integration
   - Visibility: Private/Public
   - ❌ Don't initialize with README

3. **Frontend Repo**
   - Name: `dashboard-message-center`
   - Description: Next.js frontend dashboard for customer service
   - Visibility: Private/Public
   - ❌ Don't initialize with README

**URLs:**
- Super: `https://github.com/nabilhatami86/dashboard.git`
- Backend: `https://github.com/nabilhatami86/backend-dashboard-python.git`
- Frontend: `https://github.com/nabilhatami86/dashboard-message-center.git`

---

### Step 2: Push Backend Code

```bash
cd ~/Desktop/Dashboard/backend-dashboard-python

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/

# Environment
.env

# Database
*.db
*.sqlite

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store

# Logs
*.log

# Test files
test_*.py
debug_*.sh
EOF

# Add all files
git add .

# Commit
git commit -m "Initial commit: FastAPI backend with WhatsApp integration

Features:
- FastAPI REST API
- PostgreSQL database with SQLAlchemy
- JWT authentication
- WhatsApp webhook integration (WHAPI.cloud)
- AI bot service with OpenAI
- Chat & message management
- Real-time webhook processing
"

# Add remote and push
git branch -M main
git remote add origin https://github.com/nabilhatami86/backend-dashboard-python.git
git push -u origin main
```

**Verify:** Check https://github.com/nabilhatami86/backend-dashboard-python

---

### Step 3: Push Frontend Code

```bash
cd ~/Desktop/Dashboard/dashboard-message-center

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp/
.pnp.js

# Next.js
.next/
out/
build/

# Environment
.env.local
.env.development.local
.env.test.local
.env.production.local

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Testing
coverage/

# Misc
*.tsbuildinfo
.cache/
EOF

# Add all files
git add .

# Commit
git commit -m "Initial commit: Next.js frontend dashboard

Features:
- Next.js 16 with TypeScript
- shadcn/ui components
- Tailwind CSS styling
- Zustand state management
- JWT authentication
- Real-time chat interface
- Auto-refresh every 5 seconds
- Admin & agent dashboards
- Multi-channel support (WhatsApp/Telegram/Email)
"

# Add remote and push
git branch -M main
git remote add origin https://github.com/nabilhatami86/dashboard-message-center.git
git push -u origin main
```

**Verify:** Check https://github.com/nabilhatami86/dashboard-message-center

---

### Step 4: Setup Super Repo with Submodules

#### Option A: Automatic (Recommended)

```bash
cd ~/Desktop/Dashboard

# Run setup script
./setup_git_submodules.sh
```

The script will:
1. ✅ Clear git cache
2. ✅ Create .gitignore
3. ✅ Check if submodule repos exist
4. ✅ Add submodules
5. ✅ Commit changes
6. ✅ Push to super repo

#### Option B: Manual

```bash
cd ~/Desktop/Dashboard

# 1. Clear cache
git rm -rf --cached backend-dashboard-python
git rm -rf --cached dashboard-message-center

# 2. Create .gitignore
cat > .gitignore << 'EOF'
# Submodule contents (managed separately)
backend-dashboard-python/*
dashboard-message-center/*

# But keep .git files
!.gitmodules

# Environment files
.env
.env.local

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log
EOF

# 3. Backup existing folders
mv backend-dashboard-python backend-dashboard-python.backup
mv dashboard-message-center dashboard-message-center.backup

# 4. Add submodules
git submodule add https://github.com/nabilhatami86/backend-dashboard-python.git backend-dashboard-python
git submodule add https://github.com/nabilhatami86/dashboard-message-center.git dashboard-message-center

# 5. Initialize submodules
git submodule init
git submodule update

# 6. Stage documentation files
git add *.md .gitignore .gitmodules

# 7. Commit
git commit -m "Setup: Add backend & frontend as submodules

Repository structure:
- Super repo: dashboard (documentation & orchestration)
- Submodule: backend-dashboard-python (FastAPI + PostgreSQL)
- Submodule: dashboard-message-center (Next.js + TypeScript)

Features:
- WhatsApp integration via WHAPI.cloud
- Multi-channel support (WhatsApp/Telegram/Email)
- Real-time dashboard with auto-refresh
- AI bot with OpenAI integration
- JWT authentication & role-based access
- Complete documentation & setup guides
"

# 8. Add remote and push
git remote add origin https://github.com/nabilhatami86/dashboard.git
git branch -M main
git push -u origin main
```

---

## 🔄 Working with Submodules

### Clone the Complete Project

```bash
# Clone with all submodules
git clone --recursive https://github.com/nabilhatami86/dashboard.git

# Or if already cloned
git clone https://github.com/nabilhatami86/dashboard.git
cd dashboard
git submodule init
git submodule update
```

### Update Submodules to Latest

```bash
cd ~/Desktop/Dashboard

# Update all submodules to latest from remote
git submodule update --remote --merge

# Or update specific submodule
cd backend-dashboard-python
git pull origin main
cd ..

git add backend-dashboard-python
git commit -m "Update backend submodule to latest version"
git push
```

### Make Changes to Submodule

```bash
# 1. Go to submodule directory
cd ~/Desktop/Dashboard/backend-dashboard-python

# 2. Make changes and commit
git add .
git commit -m "Add new feature"
git push origin main

# 3. Update super repo to point to new commit
cd ~/Desktop/Dashboard
git add backend-dashboard-python
git commit -m "Update backend submodule: Add new feature"
git push
```

---

## 📊 Current Status Check

```bash
cd ~/Desktop/Dashboard

# Check super repo status
git status

# Check submodule status
git submodule status

# See which commits submodules point to
git submodule
```

---

## 🐛 Common Issues

### Issue 1: Submodule folder is empty

```bash
git submodule init
git submodule update
```

### Issue 2: Detached HEAD in submodule

```bash
cd backend-dashboard-python
git checkout main
cd ..
```

### Issue 3: Submodule not updating

```bash
# Force update
git submodule update --init --recursive --remote --force
```

### Issue 4: Remove submodule

```bash
# Remove from .gitmodules
git rm --cached backend-dashboard-python
rm -rf backend-dashboard-python
git commit -m "Remove backend submodule"
```

---

## 📝 .gitmodules File

After setup, `.gitmodules` should look like:

```ini
[submodule "backend-dashboard-python"]
	path = backend-dashboard-python
	url = https://github.com/nabilhatami86/backend-dashboard-python.git
	branch = main

[submodule "dashboard-message-center"]
	path = dashboard-message-center
	url = https://github.com/nabilhatami86/dashboard-message-center.git
	branch = main
```

---

## 🎯 Benefits of This Structure

### ✅ Separation of Concerns
- Backend code isolated in its own repo
- Frontend code isolated in its own repo
- Documentation in super repo

### ✅ Independent Development
- Backend team can work independently
- Frontend team can work independently
- Each repo has its own issues, PRs, releases

### ✅ Versioning
- Each submodule can have its own version/tags
- Super repo tracks specific commits of submodules
- Easy to rollback to specific versions

### ✅ CI/CD
- Each repo can have its own CI/CD pipeline
- Deploy backend and frontend independently
- Test each component separately

---

## 🚀 Deployment with Submodules

### Railway.app

**Backend:**
```bash
cd backend-dashboard-python
railway init
railway up
```

**Frontend:**
```bash
cd dashboard-message-center
railway init
railway up
```

### Docker

**docker-compose.yml** (in super repo):
```yaml
version: '3.8'
services:
  backend:
    build: ./backend-dashboard-python
    ports:
      - "8000:8000"

  frontend:
    build: ./dashboard-message-center
    ports:
      - "3000:3000"
    depends_on:
      - backend
```

---

## 📚 Best Practices

### 1. Regular Updates
```bash
# Weekly: update submodules
git submodule update --remote --merge
```

### 2. Consistent Commits
- Commit to submodule first
- Then update super repo

### 3. Documentation
- Keep main README in super repo
- Keep specific docs in each submodule

### 4. Version Tags
```bash
# Tag backend version
cd backend-dashboard-python
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0

# Update super repo to use tagged version
cd ..
git add backend-dashboard-python
git commit -m "Update backend to v1.0.0"
```

---

## 🔗 Useful Commands

```bash
# Clone with submodules
git clone --recursive <repo-url>

# Update all submodules
git submodule update --init --recursive

# Pull latest from all submodules
git submodule foreach git pull origin main

# Show submodule changes
git submodule status

# Diff submodule commits
git diff --submodule

# Remove all submodules
git submodule deinit -f .
git rm -f backend-dashboard-python dashboard-message-center
rm -rf .git/modules/*
```

---

## 🎓 Learning Resources

- [Git Submodules Official Docs](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Pro Git Book - Submodules Chapter](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Atlassian Git Submodules Tutorial](https://www.atlassian.com/git/tutorials/git-submodule)

---

## ✅ Setup Verification

After setup, verify:

```bash
# 1. Check super repo
cd ~/Desktop/Dashboard
git remote -v
# Should show: origin https://github.com/nabilhatami86/dashboard.git

# 2. Check submodules
git submodule status
# Should show both submodules with commit hashes

# 3. Check backend
cd backend-dashboard-python
git remote -v
# Should show: origin https://github.com/nabilhatami86/backend-dashboard-python.git

# 4. Check frontend
cd ../dashboard-message-center
git remote -v
# Should show: origin https://github.com/nabilhatami86/dashboard-message-center.git

# 5. All should be on 'main' branch
git branch --show-current
```

---

**✅ Setup Complete!** Your repositories are now properly structured with submodules.
