# 💬 WhatsApp Dashboard - Multi-Channel Customer Service Platform

A full-stack real-time customer service dashboard with WhatsApp, Telegram, and Email integration. Built with **FastAPI** (Python) backend and **Next.js** (TypeScript) frontend.

![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## ✨ Features

### Core Features
- ✅ **Real-time WhatsApp Integration** - Receive and send messages via WhatsApp API
- ✅ **Multi-Channel Support** - WhatsApp, Telegram, Email in one dashboard
- ✅ **AI Bot Auto-Reply** - Intelligent auto-responses with OpenAI integration
- ✅ **Agent Assignment** - Route conversations to specific agents
- ✅ **Chat Modes** - BOT, AGENT, PAUSED, CLOSED modes
- ✅ **Real-time Updates** - Auto-refresh every 5 seconds
- ✅ **User Authentication** - JWT-based secure login
- ✅ **Role-based Access** - Admin and Agent roles

### WhatsApp Features
- 📱 Incoming message handling via webhook
- 📤 Send messages from dashboard to WhatsApp
- 🤖 Automatic bot replies
- 👤 Customer profile tracking
- 📊 Unread message counters
- ⏰ Last message timestamps
- 🔔 Online/offline status

### Dashboard Features
- 📊 **Admin Dashboard** - View all conversations across channels
- 👨‍💼 **Agent Dashboard** - View assigned conversations only
- 💬 **Chat List** - Real-time chat list with filters
- 🖼️ **Chat Window** - Message history and conversation view
- 📝 **Message Input** - Rich text input with send functionality
- 🔍 **Search & Filter** - Find conversations quickly
- 🎨 **Modern UI** - Built with shadcn/ui components

---

## 🛠️ Tech Stack

### Backend
- **FastAPI** - Modern Python web framework
- **PostgreSQL** - Reliable relational database
- **SQLAlchemy** - Python ORM
- **Pydantic** - Data validation
- **JWT** - Authentication tokens
- **WHAPI.cloud** - WhatsApp Business API

### Frontend
- **Next.js 16** - React framework
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS** - Utility-first CSS
- **shadcn/ui** - Beautiful UI components
- **Zustand** - State management
- **Lucide Icons** - Icon library

### DevOps
- **ngrok** - Development webhook tunneling
- **Uvicorn** - ASGI server
- **Docker** - Containerization (optional)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Customer Channels                        │
├─────────────┬─────────────┬─────────────┬──────────────────┤
│  WhatsApp   │  Telegram   │    Email    │   Other APIs     │
└──────┬──────┴──────┬──────┴──────┬──────┴──────┬───────────┘
       │             │             │             │
       └─────────────┴─────────────┴─────────────┘
                         │
                    (Webhooks)
                         │
                         ▼
              ┌──────────────────────┐
              │   FastAPI Backend    │
              │  ┌────────────────┐  │
              │  │   Webhook API  │  │
              │  └────────────────┘  │
              │  ┌────────────────┐  │
              │  │   Chat API     │  │
              │  └────────────────┘  │
              │  ┌────────────────┐  │
              │  │   Auth API     │  │
              │  └────────────────┘  │
              │  ┌────────────────┐  │
              │  │   Bot Service  │  │
              │  └────────────────┘  │
              └──────────┬───────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │   PostgreSQL DB      │
              │  ┌────────────────┐  │
              │  │  Chats Table   │  │
              │  ├────────────────┤  │
              │  │ Messages Table │  │
              │  ├────────────────┤  │
              │  │  Users Table   │  │
              │  └────────────────┘  │
              └──────────────────────┘
                         ▲
                         │
                    (REST API)
                         │
              ┌──────────────────────┐
              │   Next.js Frontend   │
              │  ┌────────────────┐  │
              │  │ Admin Dashboard│  │
              │  ├────────────────┤  │
              │  │ Agent Dashboard│  │
              │  ├────────────────┤  │
              │  │   Chat List    │  │
              │  ├────────────────┤  │
              │  │  Chat Window   │  │
              │  └────────────────┘  │
              └──────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │   Admin / Agent      │
              │      (Browser)       │
              └──────────────────────┘
```

### Data Flow

#### Incoming Message (WhatsApp → Dashboard)
```
Customer sends WhatsApp message
        ↓
WHAPI.cloud receives message
        ↓
POST webhook to /webhook/whapi/messages
        ↓
Backend creates/updates Chat record
        ↓
Backend saves Message to database
        ↓
If mode=BOT: Generate & send auto-reply
        ↓
Dashboard auto-refresh (5s interval)
        ↓
Agent sees message in dashboard
```

#### Outgoing Message (Dashboard → WhatsApp)
```
Agent types message in dashboard
        ↓
Click Send button
        ↓
POST /chats/messages with message data
        ↓
Backend saves message to database
        ↓
Backend calls WHAPI send_text() API
        ↓
WHAPI delivers to customer's WhatsApp
        ↓
Customer receives message
```

---

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Node.js 18+
- PostgreSQL 14+
- WHAPI.cloud account (for WhatsApp)
- ngrok (for development)

### 1. Clone Repository
```bash
git clone <repository-url>
cd Dashboard
```

### 2. Setup Backend
```bash
cd backend-dashboard-python

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup database
createdb dashboard_db

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Create demo users
python3 seed_users.py

# Start backend
python3 -m uvicorn app.main:app --reload
```

Backend runs on: `http://localhost:8000`

### 3. Setup Frontend
```bash
cd dashboard-message-center

# Install dependencies
npm install

# Configure environment
cp .env.example .env.local
# Edit .env.local

# Start frontend
npm run dev
```

Frontend runs on: `http://localhost:3000`

### 4. Setup ngrok (Development)
```bash
# Install ngrok
brew install ngrok  # macOS
# or download from https://ngrok.com

# Setup authtoken
ngrok config add-authtoken YOUR_AUTH_TOKEN

# Start tunnel
ngrok http 8000
```

Copy ngrok URL: `https://xxx.ngrok-free.app`

### 5. Configure Webhook
1. Login to https://whapi.cloud
2. Select your WhatsApp channel
3. Set webhook URL: `https://xxx.ngrok-free.app/webhook/whapi/messages`
4. Enable "Incoming Messages" event
5. Save configuration

### 6. Test WhatsApp Integration
1. Send WhatsApp message to your bot number
2. Check ngrok Web UI: `http://127.0.0.1:4040`
3. Check backend logs for "Received webhook data"
4. Open dashboard: `http://localhost:3000/login`
5. Login: `admin` / `admin123`
6. See chat appear in dashboard!

---

## 📦 Installation

### Backend Setup (Detailed)

#### 1. Database Setup
```bash
# Install PostgreSQL (macOS)
brew install postgresql@14
brew services start postgresql@14

# Create database
createdb dashboard_db

# Verify connection
psql dashboard_db
```

#### 2. Python Environment
```bash
cd backend-dashboard-python

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### 3. Environment Variables
Create `.env` file:
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dashboard_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
SECRET_KEY=your-super-secret-key-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# WhatsApp API
WHAPI_BASE_URL=https://gate.whapi.cloud
WHAPI_TOKEN=your_whapi_token_here
WHAPI_ADMINS=+6281234567890

# OpenAI (Optional - for AI bot)
OPENAI_API_KEY=sk-your-key-here
```

#### 4. Database Migration
```bash
# Tables are auto-created on first run
python3 -m uvicorn app.main:app --reload
```

#### 5. Seed Data
```bash
# Create demo users (admin/admin123, agent/agent123)
python3 seed_users.py

# Create demo chats (optional)
python3 seed_chats.py
```

### Frontend Setup (Detailed)

#### 1. Node.js Setup
```bash
cd dashboard-message-center

# Install dependencies
npm install
```

#### 2. Environment Variables
Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

#### 3. Start Development Server
```bash
npm run dev
```

### ngrok Setup (Detailed)

#### 1. Install ngrok
```bash
# macOS
brew install ngrok

# Linux
snap install ngrok

# Windows
# Download from https://ngrok.com/download
```

#### 2. Sign Up & Configure
```bash
# Sign up at https://dashboard.ngrok.com/signup
# Get authtoken from dashboard

# Configure
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

#### 3. Start Tunnel
```bash
ngrok http 8000
```

Output:
```
Forwarding    https://abc123.ngrok-free.app -> http://localhost:8000
```

#### 4. Bypass Browser Warning
- Open `https://abc123.ngrok-free.app` in browser
- Click "Visit Site" button

---

## ⚙️ Configuration

### Backend Configuration

#### Database Settings (`app/config/database.py`)
```python
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
```

#### CORS Settings (`app/main.py`)
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Add production URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

#### Chat Modes
- **BOT**: Auto-reply with AI bot
- **AGENT**: Manual agent handling
- **PAUSED**: No replies, conversation paused
- **CLOSED**: Conversation finished

### Frontend Configuration

#### API Client (`lib/api/chat.ts`)
```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
```

#### Auto-Refresh Interval (`app/dashboard-admin/page.tsx`)
```typescript
const interval = setInterval(loadChats, 5000); // 5 seconds
```

### WhatsApp Configuration

#### Webhook Events
Enable these events in WHAPI dashboard:
- ✅ Incoming Messages
- ✅ Message Status Updates (optional)
- ✅ Typing Indicators (optional)

#### Bot Service (`app/services/bot_service.py`)
```python
def handle_bot(user: str, message: str) -> Optional[str]:
    # Customize bot logic here
    # Integrates with OpenAI if OPENAI_API_KEY is set
```

---

## 📖 Usage

### Demo Accounts

| Role  | Username | Password  | Access Level |
|-------|----------|-----------|--------------|
| Admin | admin    | admin123  | All chats    |
| Agent | agent    | agent123  | Assigned chats only |

### Admin Dashboard

**URL:** `http://localhost:3000/dashboard-admin`

**Features:**
- View all conversations across all channels
- Assign chats to agents
- Switch chat modes (BOT/AGENT/PAUSED/CLOSED)
- Monitor bot performance
- Search and filter chats

**Usage:**
```bash
1. Login: http://localhost:3000/login
2. Username: admin
3. Password: admin123
4. Click on any chat to view conversation
5. Type message and click Send to reply
```

### Agent Dashboard

**URL:** `http://localhost:3000/dashboard-agent`

**Features:**
- View assigned conversations only
- Reply to customer messages
- See customer profile info
- Mark messages as read

**Usage:**
```bash
1. Login: http://localhost:3000/login
2. Username: agent
3. Password: agent123
4. See only chats assigned to you
5. Reply to customers directly
```

### WhatsApp Bot Commands

Customer can send these commands:
- `agent` - Switch to agent mode (stop bot replies)
- `bot` - Switch back to bot mode
- `pause` - Pause conversation

Admin commands (from admin number):
- `assign <number>` - Assign chat to agent
- `unassign <number>` - Remove agent assignment
- `reply <number> <text>` - Send message to customer

---

## 📚 API Documentation

### Authentication

#### POST `/auth/login`
Login with username/email and password.

**Request:**
```json
{
  "identifier": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "token_type": "bearer",
  "data": {
    "id": 1,
    "name": "Admin User",
    "role": "admin"
  }
}
```

### Chats

#### GET `/chats/`
Get all chats (filtered by role).

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "channel": "WhatsApp",
    "online": true,
    "unread": 2,
    "mode": "agent",
    "last_message_at": "2026-01-01T10:30:00"
  }
]
```

#### GET `/chats/{id}`
Get chat details with messages.

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "channel": "WhatsApp",
  "profile": {
    "phone": "+6281234567890@c.us",
    "email": null,
    "address": null,
    "lastActive": "Online"
  },
  "messages": [
    {
      "id": 1,
      "text": "Hello!",
      "sender": "customer",
      "status": "sent",
      "time": "10:30"
    }
  ]
}
```

#### POST `/chats/messages`
Send a message.

**Request:**
```json
{
  "chat_id": 1,
  "text": "Hello! How can I help?",
  "sender": "agent"
}
```

#### PATCH `/chats/{id}`
Update chat settings.

**Request:**
```json
{
  "mode": "agent",
  "assigned_agent_id": 2
}
```

### Webhooks

#### POST `/webhook/whapi/messages`
Receive WhatsApp messages (called by WHAPI.cloud).

**Payload:**
```json
{
  "messages": [{
    "from": "6281234567890@c.us",
    "from_name": "John Doe",
    "text": {"body": "Hello!"}
  }]
}
```

---

## 🚢 Deployment

### Production Deployment

#### Option 1: Railway.app (Recommended)

**Backend:**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
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

**Set Environment Variables in Railway Dashboard**

#### Option 2: VPS with Docker

**1. Create Dockerfile (Backend)**
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**2. Create Dockerfile (Frontend)**
```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build
CMD ["npm", "start"]
```

**3. Docker Compose**
```yaml
version: '3.8'
services:
  backend:
    build: ./backend-dashboard-python
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://...
    depends_on:
      - db

  frontend:
    build: ./dashboard-message-center
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=https://api.yourdomain.com

  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=dashboard_db
      - POSTGRES_PASSWORD=secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

#### Option 3: DigitalOcean/AWS/GCP

**1. Setup Server**
```bash
# SSH to server
ssh root@your-server-ip

# Install dependencies
apt update
apt install python3 python3-pip nodejs npm postgresql nginx
```

**2. Configure Nginx**
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

**3. Setup SSL with Let's Encrypt**
```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com
```

**4. Update Webhook URL**
```
https://yourdomain.com/webhook/whapi/messages
```

---

## 🐛 Troubleshooting

### WhatsApp Messages Not Arriving

**Problem:** Send WhatsApp but message doesn't appear in dashboard

**Solutions:**
1. Check ngrok Web UI (`http://127.0.0.1:4040`) - Do you see POST requests?
2. Verify webhook URL in WHAPI dashboard
3. Bypass ngrok browser warning (visit ngrok URL in browser)
4. Check backend logs for "Received webhook data"
5. Verify ngrok is still running: `ps aux | grep ngrok`

### Bot Not Replying

**Problem:** Bot doesn't auto-reply to messages

**Solutions:**
1. Check chat mode: `curl http://localhost:8000/chats/1` - mode should be "bot"
2. Verify WHAPI_TOKEN in `.env`
3. Check backend logs for errors
4. Test bot service: `python3 -c "from app.services.bot_service import handle_bot; print(handle_bot('test', 'hello'))"`

### Dashboard Not Updating

**Problem:** New messages don't appear in dashboard

**Solutions:**
1. Check browser console (F12) for errors
2. Verify API URL: `.env.local` should have correct `NEXT_PUBLIC_API_URL`
3. Test API manually: `curl http://localhost:8000/chats/`
4. Check auto-refresh is working (should refresh every 5s)
5. Hard refresh browser: Ctrl+Shift+R

### Database Connection Errors

**Problem:** "Cannot connect to database"

**Solutions:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Start PostgreSQL
brew services start postgresql@14

# Test connection
psql dashboard_db

# Check credentials in .env
echo $DB_HOST $DB_PORT $DB_NAME
```

### CORS Errors

**Problem:** "CORS policy blocked request"

**Solutions:**
1. Add frontend URL to CORS origins in `app/main.py`:
```python
allow_origins=["http://localhost:3000", "https://yourdomain.com"]
```
2. Restart backend server
3. Clear browser cache

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## 📞 Support

- **Documentation:** See `docs/` folder
- **Issues:** [GitHub Issues](https://github.com/your-repo/issues)
- **Email:** support@yourdomain.com

---

## 🎯 Roadmap

### Current Features (v1.0)
- ✅ WhatsApp integration
- ✅ Multi-channel support
- ✅ AI bot auto-reply
- ✅ Admin & agent dashboards
- ✅ Real-time updates

### Planned Features (v2.0)
- [ ] Media message support (images, videos, files)
- [ ] Group chat support
- [ ] Broadcast messages
- [ ] Message templates
- [ ] Analytics dashboard
- [ ] Export chat history
- [ ] Mobile app (React Native)
- [ ] Voice messages
- [ ] Video calls
- [ ] Integration with more channels (Instagram, Facebook, LINE)

---

## 🙏 Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Next.js](https://nextjs.org/) - React framework
- [WHAPI.cloud](https://whapi.cloud/) - WhatsApp Business API
- [shadcn/ui](https://ui.shadcn.com/) - Beautiful UI components
- [PostgreSQL](https://www.postgresql.org/) - Powerful database

---

**Built with ❤️ by Your Team**

**Last Updated:** January 2026
