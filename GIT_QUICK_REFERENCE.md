# 🚀 Git Submodules - Quick Reference

## 📋 Initial Setup (One-time)

### 1. Create GitHub Repos
```bash
# Go to https://github.com/new and create:
# 1. dashboard
# 2. backend-dashboard-python
# 3. dashboard-message-center
```

### 2. Push Backend
```bash
cd ~/Desktop/Dashboard/backend-dashboard-python
git init
git add .
git commit -m "Initial commit: FastAPI backend"
git branch -M main
git remote add origin https://github.com/nabilhatami86/backend-dashboard-python.git
git push -u origin main
```

### 3. Push Frontend
```bash
cd ~/Desktop/Dashboard/dashboard-message-center
git init
git add .
git commit -m "Initial commit: Next.js frontend"
git branch -M main
git remote add origin https://github.com/nabilhatami86/dashboard-message-center.git
git push -u origin main
```

### 4. Setup Super Repo (AUTOMATIC)
```bash
cd ~/Desktop/Dashboard
./setup_git_submodules.sh
```

**OR Manual:**
```bash
cd ~/Desktop/Dashboard

# Backup existing folders
mv backend-dashboard-python backend-dashboard-python.backup
mv dashboard-message-center dashboard-message-center.backup

# Add as submodules
git submodule add https://github.com/nabilhatami86/backend-dashboard-python.git
git submodule add https://github.com/nabilhatami86/dashboard-message-center.git

# Commit and push
git add .gitmodules *.md .gitignore
git commit -m "Setup submodules"
git remote add origin https://github.com/nabilhatami86/dashboard.git
git branch -M main
git push -u origin main
```

---

## 🔄 Daily Workflow

### Clone Project (New Machine)
```bash
git clone --recursive https://github.com/nabilhatami86/dashboard.git
cd dashboard
```

### Update Submodules to Latest
```bash
cd ~/Desktop/Dashboard
git submodule update --remote --merge
git add .
git commit -m "Update submodules to latest"
git push
```

### Make Changes to Backend
```bash
cd ~/Desktop/Dashboard/backend-dashboard-python

# Make changes...
git add .
git commit -m "Add new feature"
git push origin main

# Update super repo
cd ..
git add backend-dashboard-python
git commit -m "Update backend submodule"
git push
```

### Make Changes to Frontend
```bash
cd ~/Desktop/Dashboard/dashboard-message-center

# Make changes...
git add .
git commit -m "Update UI"
git push origin main

# Update super repo
cd ..
git add dashboard-message-center
git commit -m "Update frontend submodule"
git push
```

### Update Documentation (Super Repo Only)
```bash
cd ~/Desktop/Dashboard

# Edit README.md or other docs
git add *.md
git commit -m "Update documentation"
git push
```

---

## 🐛 Common Commands

### Check Status
```bash
cd ~/Desktop/Dashboard

# Super repo status
git status

# Submodule status
git submodule status

# Show submodule details
git submodule
```

### Sync Everything
```bash
# Pull super repo
git pull

# Update all submodules
git submodule update --init --recursive --remote

# Or update and merge
git submodule foreach git pull origin main
```

### Fix Detached HEAD
```bash
cd backend-dashboard-python
git checkout main
git pull origin main
cd ..
```

### Reset Submodule
```bash
# Reset to committed version
git submodule update --init --force

# Or specific submodule
cd backend-dashboard-python
git reset --hard origin/main
cd ..
```

---

## 📊 Checking Versions

### See Current Submodule Commits
```bash
cd ~/Desktop/Dashboard
git submodule status

# Output example:
# 3a7f8b2 backend-dashboard-python (heads/main)
# 5c9d1e4 dashboard-message-center (heads/main)
```

### See Submodule Changes
```bash
git diff --submodule
```

### List All Submodules
```bash
git submodule
```

---

## 🔗 Repository URLs

```bash
# Super Repo
https://github.com/nabilhatami86/dashboard.git

# Backend Submodule
https://github.com/nabilhatami86/backend-dashboard-python.git

# Frontend Submodule
https://github.com/nabilhatami86/dashboard-message-center.git
```

---

## ⚡ Quick Fixes

### Submodule folder empty
```bash
git submodule update --init --recursive
```

### Can't push to submodule
```bash
cd backend-dashboard-python
git checkout main
# Make changes
git push origin main
cd ..
git add backend-dashboard-python
git commit -m "Update backend"
git push
```

### Remove submodule
```bash
# DON'T do this unless you know what you're doing!
git submodule deinit -f backend-dashboard-python
git rm -f backend-dashboard-python
rm -rf .git/modules/backend-dashboard-python
git commit -m "Remove backend submodule"
```

---

## 🎯 Best Practices

1. ✅ **Always commit to submodule first**, then update super repo
2. ✅ **Use descriptive commit messages** in both repos
3. ✅ **Update submodules regularly** to stay in sync
4. ✅ **Test after updating** submodules
5. ✅ **Document changes** in README files

---

## 📝 Commit Message Templates

### Backend Changes
```bash
git commit -m "Backend: Add WhatsApp media message support

- Handle image/video messages
- Store media URLs in database
- Update webhook handler
"
```

### Frontend Changes
```bash
git commit -m "Frontend: Add media message preview

- Display images in chat window
- Add video playback support
- Update chat list thumbnails
"
```

### Super Repo Updates
```bash
git commit -m "Update submodules to latest versions

Backend: v1.2.0 - Media message support
Frontend: v1.2.0 - Media preview UI
"
```

---

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| Submodule not updating | `git submodule update --init --recursive --force` |
| Detached HEAD warning | `cd <submodule> && git checkout main` |
| Can't push changes | Check you're on `main` branch |
| Merge conflicts | Resolve in submodule, then update super repo |
| Wrong commit tracked | Update submodule, `git add`, commit, push |

---

## 🎓 Learn More

- Full Guide: [GIT_SETUP_GUIDE.md](GIT_SETUP_GUIDE.md)
- Git Submodules Docs: https://git-scm.com/book/en/v2/Git-Tools-Submodules
- Setup Script: [setup_git_submodules.sh](setup_git_submodules.sh)

---

**Last Updated:** January 1, 2026
