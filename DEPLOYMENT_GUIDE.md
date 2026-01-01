# 🚀 Deployment Guide - Free Hosting

Deploy your WhatsApp Dashboard to production using **free tier** hosting services.

---

## 📋 Deployment Strategy

### Frontend → Vercel (Free)
- **Service:** Vercel
- **What:** Next.js frontend dashboard
- **URL:** `https://your-app.vercel.app`
- **Features:** Auto-deploy from GitHub, SSL, CDN

### Backend → Railway (Free Trial) or Render (Free)
- **Service:** Railway.app or Render.com
- **What:** FastAPI backend + PostgreSQL
- **URL:** `https://your-app.railway.app` or `https://your-app.onrender.com`
- **Features:** Free PostgreSQL, auto-deploy

---

## 🎯 Option 1: Vercel + Railway (Recommended)

### A. Deploy Backend to Railway

#### 1. Create Railway Account
- Visit: https://railway.app
- Sign up with GitHub
- Free trial: $5 credit (enough for ~1 month)

#### 2. Create New Project
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Navigate to backend
cd ~/Desktop/Dashboard/backend-dashboard-python

# Initialize Railway project
railway init

# Link to existing project (or create new)
railway link
```

#### 3. Add PostgreSQL Database
```bash
# Add PostgreSQL service
railway add postgresql

# Railway will automatically set DATABASE_URL
```

#### 4. Configure Environment Variables

In Railway Dashboard → Variables:
```env
# Database (auto-set by Railway)
DATABASE_URL=postgresql://...

# JWT
SECRET_KEY=your-super-secret-key-here-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# WhatsApp
WHAPI_BASE_URL=https://gate.whapi.cloud
WHAPI_TOKEN=your_whapi_token_here

# OpenAI (optional)
OPENAI_API_KEY=sk-your-key-here
```

#### 5. Create `railway.json`
```bash
cd ~/Desktop/Dashboard/backend-dashboard-python

cat > railway.json << 'EOF'
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/",
    "restartPolicyType": "ON_FAILURE"
  }
}
EOF

git add railway.json
git commit -m "Add Railway configuration"
git push origin main
```

#### 6. Deploy
```bash
railway up

# Or deploy from GitHub (recommended)
# Link GitHub repo in Railway dashboard
# Auto-deploy on every push to main
```

#### 7. Get Backend URL
```bash
railway domain

# Example output: https://backend-production-abc123.railway.app
```

#### 8. Update WHAPI Webhook
- Login to https://whapi.cloud
- Update webhook URL:
  ```
  https://backend-production-abc123.railway.app/webhook/whapi/messages
  ```

---

### B. Deploy Frontend to Vercel

#### 1. Create Vercel Account
- Visit: https://vercel.com
- Sign up with GitHub
- Free tier: Unlimited personal projects

#### 2. Install Vercel CLI (Optional)
```bash
npm install -g vercel
vercel login
```

#### 3. Prepare Frontend for Deployment

```bash
cd ~/Desktop/Dashboard/dashboard-message-center

# Create vercel.json
cat > vercel.json << 'EOF'
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "regions": ["sin1"]
}
EOF

git add vercel.json
git commit -m "Add Vercel configuration"
git push origin main
```

#### 4. Deploy via Vercel Dashboard (Easiest)

1. Go to https://vercel.com/dashboard
2. Click **"Add New Project"**
3. Import from GitHub: `nabilhatami86/dashboard-message-center`
4. Configure:
   - **Framework Preset:** Next.js
   - **Root Directory:** `./` (default)
   - **Build Command:** `npm run build` (default)
   - **Output Directory:** `.next` (default)

5. **Environment Variables:**
   ```
   NEXT_PUBLIC_API_URL = https://backend-production-abc123.railway.app
   ```
   (Use your Railway backend URL)

6. Click **Deploy**

#### 5. Get Frontend URL
After deployment completes:
```
https://dashboard-message-center.vercel.app
```

Or custom domain if you have one.

---

## 🎯 Option 2: Render (Both Backend + Frontend)

### A. Deploy Backend to Render

#### 1. Create Render Account
- Visit: https://render.com
- Sign up with GitHub
- Free tier available

#### 2. Create New Web Service
1. Dashboard → **New** → **Web Service**
2. Connect GitHub repo: `nabilhatami86/backend-dashboard-python`
3. Configure:
   - **Name:** `dashboard-backend`
   - **Environment:** Python 3
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Plan:** Free

#### 3. Add PostgreSQL Database
1. Dashboard → **New** → **PostgreSQL**
2. Name: `dashboard-db`
3. Plan: Free
4. Create

5. Copy **Internal Database URL**

#### 4. Environment Variables
In Web Service → Environment:
```env
DATABASE_URL=postgresql://...  (from PostgreSQL service)
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080
WHAPI_BASE_URL=https://gate.whapi.cloud
WHAPI_TOKEN=your_token
```

#### 5. Get Backend URL
```
https://dashboard-backend.onrender.com
```

---

### B. Deploy Frontend to Render

#### 1. Create New Static Site
1. Dashboard → **New** → **Static Site**
2. Connect repo: `nabilhatami86/dashboard-message-center`
3. Configure:
   - **Name:** `dashboard-frontend`
   - **Build Command:** `npm run build`
   - **Publish Directory:** `.next`
   - **Plan:** Free

#### 2. Environment Variables
```env
NEXT_PUBLIC_API_URL=https://dashboard-backend.onrender.com
```

#### 3. Get Frontend URL
```
https://dashboard-frontend.onrender.com
```

---

## 🎯 Option 3: Netlify (Frontend Only)

### Deploy Frontend to Netlify

#### 1. Create Netlify Account
- Visit: https://netlify.com
- Sign up with GitHub
- Free tier: 100GB bandwidth/month

#### 2. Deploy via Netlify Dashboard
1. Dashboard → **Add new site** → **Import from Git**
2. Connect GitHub: `nabilhatami86/dashboard-message-center`
3. Configure:
   - **Build command:** `npm run build`
   - **Publish directory:** `.next`
   - **Environment variables:**
     ```
     NEXT_PUBLIC_API_URL = https://your-backend-url.railway.app
     ```

4. Click **Deploy site**

#### 3. Get URL
```
https://dashboard-message-center.netlify.app
```

---

## 📋 Deployment Checklist

### Before Deployment

#### Backend
- [ ] Remove `.env` from git (add to .gitignore)
- [ ] Create `.env.example` with template
- [ ] Update CORS origins to include production URLs
- [ ] Test database migrations
- [ ] Add health check endpoint

#### Frontend
- [ ] Update API URL to use environment variable
- [ ] Test build locally: `npm run build`
- [ ] Remove console.logs from production code
- [ ] Add proper error handling
- [ ] Configure redirects if needed

---

## 🔧 Configuration Files

### Backend: `railway.json` or `render.yaml`

**Railway:**
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/",
    "restartPolicyType": "ON_FAILURE"
  }
}
```

**Render (`render.yaml`):**
```yaml
services:
  - type: web
    name: dashboard-backend
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: dashboard-db
          property: connectionString
      - key: SECRET_KEY
        sync: false
      - key: WHAPI_TOKEN
        sync: false

databases:
  - name: dashboard-db
    plan: free
```

### Frontend: `vercel.json`

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "regions": ["sin1"],
  "env": {
    "NEXT_PUBLIC_API_URL": "@backend-url"
  }
}
```

---

## 🔒 Update CORS for Production

**Backend (`app/main.py`):**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # Development
        "https://dashboard-message-center.vercel.app",  # Production frontend
        "https://your-custom-domain.com",  # Custom domain (if any)
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 🌐 Update WhatsApp Webhook

After backend deployment, update webhook in WHAPI:

**Development:**
```
https://your-ngrok-url.ngrok-free.app/webhook/whapi/messages
```

**Production:**
```
https://dashboard-backend.railway.app/webhook/whapi/messages
```

Or:
```
https://dashboard-backend.onrender.com/webhook/whapi/messages
```

---

## 🎯 Recommended Setup (Best Free Tier)

| Service | Free Tier | Best For |
|---------|-----------|----------|
| **Vercel** | Unlimited personal projects | ⭐ Frontend (Next.js) |
| **Railway** | $5 credit (~1 month) | Backend + Database |
| **Render** | 750 hours/month | Backend + Database |
| **Supabase** | 500MB database | PostgreSQL alternative |
| **PlanetScale** | 5GB storage | MySQL alternative |

**Recommended Combo:**
- **Frontend:** Vercel (unlimited free)
- **Backend:** Railway ($5 trial then $5/month) or Render (free but sleeps after 15min inactivity)
- **Database:** Included with Railway/Render

---

## 💰 Cost Comparison

### Free Forever
- **Vercel Frontend:** ✅ Free (unlimited)
- **Render Backend + DB:** ✅ Free (with sleep after 15min inactivity)

### Paid (After Free Trial)
- **Railway:** ~$5-10/month (pay-as-you-go)
- **Vercel Pro:** $20/month (optional, for custom domains)

---

## 🚀 Quick Deploy Commands

### Deploy Backend to Railway
```bash
cd backend-dashboard-python
railway login
railway init
railway add postgresql
railway up
railway domain
```

### Deploy Frontend to Vercel
```bash
cd dashboard-message-center
vercel login
vercel
# Follow prompts
```

---

## 📊 Post-Deployment Checklist

- [ ] Backend URL accessible: `https://backend.railway.app/`
- [ ] Frontend URL accessible: `https://frontend.vercel.app/`
- [ ] Database connected: Check `/db-connect` endpoint
- [ ] CORS configured for production domain
- [ ] WhatsApp webhook updated to production URL
- [ ] Environment variables set correctly
- [ ] Test login with demo accounts
- [ ] Test WhatsApp message flow
- [ ] Monitor logs for errors

---

## 🐛 Common Deployment Issues

### Backend won't start
**Solution:** Check logs for missing environment variables
```bash
railway logs
# or
render logs
```

### Database connection failed
**Solution:** Verify DATABASE_URL is set correctly
```bash
railway variables
```

### CORS errors
**Solution:** Add production frontend URL to CORS origins in `app/main.py`

### Frontend can't connect to backend
**Solution:** Check `NEXT_PUBLIC_API_URL` environment variable in Vercel

---

## 📚 Additional Resources

- [Vercel Docs](https://vercel.com/docs)
- [Railway Docs](https://docs.railway.app)
- [Render Docs](https://render.com/docs)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)

---

**Ready to deploy? Let's go! 🚀**

**Last Updated:** January 1, 2026
