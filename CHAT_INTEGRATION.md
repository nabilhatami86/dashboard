# 💬 Chat Integration Documentation

## Overview
Sistem chat telah sepenuhnya terintegrasi dengan backend Python (FastAPI) dan frontend Next.js. Chat real-time dengan auto-refresh setiap 5 detik.

---

## 🎯 Fitur Chat yang Sudah Terintegrasi

### Backend Features ✅
- ✅ Database models untuk Chat & Message
- ✅ REST API endpoints untuk CRUD operations
- ✅ Chat modes: bot, agent, paused, closed
- ✅ Assign chat to agent
- ✅ Track unread messages
- ✅ Message sender tracking (customer/agent)
- ✅ Multi-channel support (WhatsApp, Telegram, Email)

### Frontend Features ✅
- ✅ Real-time chat list (auto-refresh 5s)
- ✅ Send & receive messages via API
- ✅ No more dummy data - all from backend
- ✅ Loading states & empty states
- ✅ Agent & Admin dashboard integration
- ✅ Mark messages as read
- ✅ Bot auto-reply in bot mode

---

## 📊 Database Schema

### Chat Table
```sql
CREATE TABLE chats (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR NOT NULL,
    customer_phone VARCHAR,
    customer_email VARCHAR,
    customer_address VARCHAR,
    channel ENUM('WhatsApp', 'Telegram', 'Email'),
    mode ENUM('bot', 'agent', 'paused', 'closed'),
    online BOOLEAN DEFAULT FALSE,
    unread_count INTEGER DEFAULT 0,
    assigned_agent_id INTEGER REFERENCES users(id),
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

### Message Table
```sql
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER REFERENCES chats(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    sender ENUM('customer', 'agent'),
    status ENUM('sent', 'read'),
    agent_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE
);
```

---

## 🔌 API Endpoints

### Get All Chats
```http
GET /chats/
Authorization: Bearer {token}
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
    "last_message_at": "2026-01-01T10:37:28+07:00"
  }
]
```

### Get Chat Detail
```http
GET /chats/{chat_id}
```

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "channel": "WhatsApp",
  "online": true,
  "unread": 2,
  "mode": "agent",
  "profile": {
    "phone": "+62 812-3456-7890",
    "email": "john.doe@email.com",
    "address": "Jakarta Selatan",
    "lastActive": "Online"
  },
  "messages": [
    {
      "id": 1,
      "text": "Halo!",
      "sender": "customer",
      "status": "read",
      "time": "10:27"
    }
  ]
}
```

### Create Chat
```http
POST /chats/
Content-Type: application/json

{
  "customer_name": "New Customer",
  "customer_phone": "+62 812-xxxx-xxxx",
  "customer_email": "customer@email.com",
  "customer_address": "Jakarta",
  "channel": "WhatsApp"
}
```

### Update Chat
```http
PATCH /chats/{chat_id}
Content-Type: application/json

{
  "mode": "agent",
  "assigned_agent_id": 2,
  "online": true
}
```

### Send Message
```http
POST /chats/messages
Authorization: Bearer {token}
Content-Type: application/json

{
  "chat_id": 1,
  "text": "Hello, how can I help?",
  "sender": "agent"
}
```

### Mark as Read
```http
POST /chats/{chat_id}/read
```

---

## 🎨 Frontend Implementation

### Chat List Integration
**File:** [dashboard-admin/page.tsx](dashboard-message-center/app/dashboard-admin/page.tsx)

**Key Features:**
- Auto-refresh every 5 seconds
- Loads chats from backend via `chatApi.getAllChats()`
- Optimistic UI updates
- Loading & empty states

```typescript
const loadChats = useCallback(async () => {
  const chatList = await chatApi.getAllChats();
  const fullChats = await Promise.all(
    chatList.map(item => chatApi.getChatDetail(item.id))
  );
  setChats(fullChats);
}, [activeChatId]);

useEffect(() => {
  loadChats();
  const interval = setInterval(loadChats, 5000);
  return () => clearInterval(interval);
}, [loadChats]);
```

### Send Message Integration
```typescript
const handleSendMessage = async (text: string) => {
  const newMessage = await chatApi.sendMessage({
    chat_id: activeChatId,
    text,
    sender: "agent",
  });

  // Update UI optimistically
  setChats(prev =>
    prev.map(chat =>
      chat.id === activeChatId
        ? { ...chat, messages: [...chat.messages, newMessage] }
        : chat
    )
  );
};
```

### Chat Mode Management
```typescript
// Assign to agent
const assignToAgent = async () => {
  await chatApi.updateChat(activeChatId, { mode: "agent" });
  await loadChatDetail(activeChatId);
};

// Pause chat
const handlePauseChat = async (mode: "paused" | "bot") => {
  await chatApi.updateChat(activeChatId, { mode });
  await loadChatDetail(activeChatId);
};
```

---

## 🚀 Setup & Testing

### 1. Run Backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
source .venv/bin/activate

# Create database tables (automatic on startup)
uvicorn app.main:app --reload --port 8000
```

### 2. Seed Demo Data
```bash
# Create demo users (if not already created)
python3 seed_users.py

# Create demo chats
python3 seed_chats.py
```

**Demo Chats Created:**
1. **John Doe** - Agent mode, 2 unread, assigned to agent
2. **Sarah Williams** - Bot mode, 0 unread
3. **Maria Lopez** - Bot mode, 1 unread, unassigned
4. **Ahmed Hassan** - Paused mode, assigned to agent

### 3. Run Frontend
```bash
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
npm run dev
```

### 4. Test Flow

#### As Admin:
1. Login as `admin` / `admin123`
2. Go to dashboard - you should see 4 chats
3. Click on a chat to view messages
4. Send a message as agent
5. Try "Assign to Agent" or "Pause Chat" buttons

#### As Agent:
1. Login as `agent` / `agent123`
2. Go to dashboard - you should see 2 assigned chats
   - John Doe
   - Ahmed Hassan
3. Send messages to customers
4. Messages auto-save to database

---

## 🔍 Testing API Manually

### Get All Chats
```bash
curl http://localhost:8000/chats/
```

### Get Chat Detail
```bash
curl http://localhost:8000/chats/1
```

### Send Message (with auth)
```bash
# First login to get token
TOKEN=$(curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin","password":"admin123"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Send message
curl -X POST http://localhost:8000/chats/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": 1,
    "text": "Test message from API",
    "sender": "agent"
  }'
```

### Update Chat Mode
```bash
curl -X PATCH http://localhost:8000/chats/1 \
  -H "Content-Type: application/json" \
  -d '{"mode": "agent"}'
```

---

## 📁 File Structure

### Backend
```
backend-dashboard-python/
├── app/
│   ├── models/
│   │   ├── chat.py          # Chat model
│   │   └── message.py       # Message model
│   ├── schemas/
│   │   └── chat_schema.py   # Pydantic schemas
│   ├── controller/
│   │   └── chat_controller.py  # Business logic
│   ├── routes/
│   │   └── chat.py          # API routes
│   └── main.py              # FastAPI app
├── seed_chats.py            # Demo data seeder
└── seed_users.py            # User seeder
```

### Frontend
```
dashboard-message-center/
├── lib/
│   └── api/
│       └── chat.ts          # Chat API client
├── app/
│   ├── types/
│   │   └── types.tsx        # TypeScript types
│   ├── dashboard-admin/
│   │   └── page.tsx         # Admin dashboard (integrated)
│   └── dashboard-agent/
│       └── page.tsx         # Agent dashboard (integrated)
└── components/
    ├── chat/
    │   ├── chat-list.tsx    # Chat list component
    │   ├── chat-window.tsx  # Chat window for admin
    │   └── chat-window-agent.tsx  # Chat window for agent
    └── customer/
        └── customer-detail.tsx    # Customer info panel
```

---

## 🎯 Chat Flow

### 1. Customer Sends Message (via WhatsApp/Telegram)
```
Webhook receives message
  ↓
Creates/Updates Chat in database
  ↓
Saves Message to database
  ↓
If mode = "bot": Auto-reply
  ↓
Frontend auto-refreshes (5s interval)
  ↓
Admin/Agent sees new message
```

### 2. Agent Replies
```
Agent types message in dashboard
  ↓
POST /chats/messages
  ↓
Message saved to database
  ↓
Optimistic UI update (instant)
  ↓
Next refresh confirms from backend
  ↓
(Future: Send to WhatsApp/Telegram via API)
```

### 3. Assign to Agent
```
Admin clicks "Assign to Agent"
  ↓
PATCH /chats/{id} with mode="agent"
  ↓
Chat mode updated in database
  ↓
Agent dashboard now shows the chat
  ↓
Bot stops auto-replying
```

---

## 🔐 Authentication & Authorization

### Token-based Auth
- Frontend stores JWT token in localStorage
- Token automatically included in API requests
- Token contains user ID and role

### Role-based Access
- **Admin**: Can see all chats
- **Agent**: Only sees assigned chats (filtered by `assigned_agent_id`)

**Implementation:**
```python
# In chat_controller.py
def get_all_chats(db, user_id, user_role):
    query = db.query(Chat)

    # If user is agent, filter by assigned chats
    if user_role == "agent" and user_id:
        query = query.filter(Chat.assigned_agent_id == user_id)

    return query.all()
```

---

## 🐛 Troubleshooting

### Chats Not Loading
**Problem**: Frontend shows "No chats available"

**Solutions**:
1. Check backend is running: `curl http://localhost:8000/chats/`
2. Run seed script: `python3 seed_chats.py`
3. Check browser console for errors
4. Verify token is valid (localStorage → auth-storage)

### Messages Not Sending
**Problem**: Message doesn't appear after clicking send

**Solutions**:
1. Check browser console for API errors
2. Verify user is logged in (token exists)
3. Test API directly:
   ```bash
   curl -X POST http://localhost:8000/chats/messages \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"chat_id":1,"text":"test","sender":"agent"}'
   ```

### Agent Can't See Chats
**Problem**: Agent dashboard shows "No assigned chats"

**Solutions**:
1. Check if chats are assigned to the agent in database
2. Login as admin and assign chats manually
3. Or reseed data: `python3 seed_chats.py`

### CORS Errors
**Problem**: Browser blocks API requests

**Solution**:
Ensure CORS is configured in `main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## ✨ Next Steps / Future Enhancements

### Immediate Improvements
1. ✅ **Done**: Basic chat CRUD
2. ✅ **Done**: Real-time refresh (polling)
3. 🔄 **Todo**: WebSocket for instant updates
4. 🔄 **Todo**: Send messages to actual WhatsApp/Telegram
5. 🔄 **Todo**: File/image message support
6. 🔄 **Todo**: Message reactions
7. 🔄 **Todo**: Typing indicators

### Advanced Features
- Search/filter chats
- Chat analytics (response time, resolution rate)
- Canned responses / Templates
- Chat transfer between agents
- Customer satisfaction ratings
- Chat history export
- Multi-language support

---

## 📊 Performance Notes

### Current Implementation
- **Polling Interval**: 5 seconds
- **Initial Load**: Fetches all chats + details (can be slow with many chats)
- **Optimistic Updates**: Messages appear instantly, then confirmed by next refresh

### Optimization Recommendations
1. **Pagination**: Load chats in batches of 20-50
2. **WebSocket**: Replace polling with real-time WebSocket
3. **Lazy Loading**: Load chat details only when selected
4. **Caching**: Cache chat list to reduce API calls
5. **Incremental Updates**: Only fetch new/updated chats

---

**Happy Chatting! 💬🎉**
