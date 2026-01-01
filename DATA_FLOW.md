# 📊 Data Flow Documentation - Real Data (No Dummy!)

## Overview
**SEMUA DATA SEKARANG REAL** - Tidak ada dummy data lagi! Chat list di dashboard menampilkan data langsung dari database yang diisi oleh WhatsApp webhook atau channel lainnya.

---

## 🔄 Complete Data Flow

### 1. WhatsApp Message → Database
```
Customer kirim WhatsApp message
        ↓
Webhook /webhook/whapi receives
        ↓
get_or_create_chat(phone, name)
  ├─ Cek database: chat exists?
  ├─ YES: Update online & last_message_at
  └─ NO: Create new Chat record
        ↓
save_customer_message(chat, text)
  ├─ Create Message record
  ├─ Increment chat.unread_count
  └─ Update chat.last_message_at
        ↓
Database now has:
  ├─ chats table: 1 row (customer info)
  └─ messages table: 1 row (customer message)
```

### 2. Database → Dashboard (Auto-Refresh)
```
Dashboard page loads
        ↓
loadChats() called
        ↓
API: GET /chats/
  ├─ Backend queries database
  ├─ Returns list of chats
  └─ Each chat: {id, name, channel, unread, ...}
        ↓
For each chat ID:
  API: GET /chats/{id}
    ├─ Backend queries Chat + Messages
    ├─ Joins tables
    └─ Returns full chat with messages
        ↓
Frontend state updated
        ↓
ChatList component re-renders
        ↓
Shows REAL chats from database:
  ├─ Customer name from WhatsApp
  ├─ Last message preview
  ├─ Unread count from database
  └─ Channel badge (WhatsApp/Telegram/Email)
        ↓
Auto-refresh every 5 seconds (loop)
```

### 3. Agent Reply → WhatsApp
```
Agent types message in dashboard
        ↓
Click Send button
        ↓
handleSendMessage(text)
        ↓
API: POST /chats/messages
  {
    chat_id: 1,
    text: "Hello!",
    sender: "agent"
  }
        ↓
Backend controller:
  ├─ Save message to database
  ├─ Update chat.last_message_at
  ├─ Check if chat is WhatsApp
  └─ YES: send_text(phone, text) ← Send to WhatsApp!
        ↓
WhatsApp API delivers message
        ↓
Customer receives on WhatsApp
        ↓
Database has new Message record
        ↓
Dashboard auto-refresh shows new message
```

---

## 📁 Components & Data Sources

### ChatList Component
**File:** `components/chat/chat-list.tsx`

**Data Source:** Props dari parent (dashboard page)
```tsx
<ChatList
  chats={chats}              // ← REAL data dari API
  activeChatId={activeChatId}
  onSelectChat={setActiveChat}
/>
```

**NO DUMMY DATA:**
- ✅ No `initialChats` constant
- ✅ No hardcoded chat arrays
- ✅ All data from `chats` prop
- ✅ `chats` prop comes from API calls

**What It Displays:**
```tsx
{filteredChats.map((chat) => (
  <div>
    <Avatar>{chat.name}</Avatar>        // ← From database
    <p>{chat.name}</p>                  // ← From database
    <p>{lastMessage?.text}</p>          // ← From database
    <Badge>{unreadCount}</Badge>        // ← Calculated from messages
  </div>
))}
```

### Admin Dashboard
**File:** `app/dashboard-admin/page.tsx`

**Data Loading:**
```tsx
const loadChats = useCallback(async () => {
  // 1. Get all chats from API
  const chatList = await chatApi.getAllChats();

  // 2. Get full details for each chat
  const fullChats = await Promise.all(
    chatList.map(item => chatApi.getChatDetail(item.id))
  );

  // 3. Update state with REAL data
  setChats(fullChats);
}, []);

// Auto-refresh every 5 seconds
useEffect(() => {
  loadChats();
  const interval = setInterval(loadChats, 5000);
  return () => clearInterval(interval);
}, [loadChats]);
```

**Data passed to ChatList:**
```tsx
<ChatList
  chats={chats}  // ← From API, refreshed every 5s
  ...
/>
```

### Agent Dashboard
**File:** `app/dashboard-agent/page.tsx`

**Same pattern as Admin:**
```tsx
const loadChats = useCallback(async () => {
  const chatList = await chatApi.getAllChats();  // ← Filtered by agent_id
  const fullChats = await Promise.all(...);
  setChats(fullChats);
}, []);
```

**Difference:** Backend filters by `assigned_agent_id`
```python
# In chat_controller.py
if user_role == "agent" and user_id:
    query = query.filter(Chat.assigned_agent_id == user_id)
```

---

## 🗄️ Database Tables

### chats Table (Real Data)
```sql
SELECT * FROM chats;

id | customer_name  | customer_phone       | channel   | mode   | online | unread_count
---|----------------|---------------------|-----------|--------|--------|-------------
1  | John Doe       | +6281234567890@c.us | WhatsApp  | agent  | true   | 2
2  | Sarah Williams | +15550123@c.us      | WhatsApp  | bot    | false  | 0
3  | Maria Lopez    | +34612998221@c.us   | WhatsApp  | bot    | true   | 1
```

### messages Table (Real Messages)
```sql
SELECT * FROM messages WHERE chat_id = 1;

id | chat_id | text                          | sender   | status | created_at
---|---------|-------------------------------|----------|--------|------------------
1  | 1       | Halo, saya butuh bantuan!     | customer | sent   | 2026-01-01 10:27
2  | 1       | Halo! Ada yang bisa dibantu?  | agent    | sent   | 2026-01-01 10:28
3  | 1       | Saya ingin tanya produk       | customer | sent   | 2026-01-01 10:36
```

---

## 🔍 API Endpoints & Responses

### GET /chats/ - List All Chats
**Request:**
```http
GET http://localhost:8000/chats/
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
  },
  {
    "id": 2,
    "name": "Sarah Williams",
    "channel": "WhatsApp",
    "online": false,
    "unread": 0,
    "mode": "bot",
    "last_message_at": "2026-01-01T08:37:28+07:00"
  }
]
```

### GET /chats/{id} - Get Chat Detail
**Request:**
```http
GET http://localhost:8000/chats/1
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
    "phone": "+6281234567890@c.us",
    "email": null,
    "address": null,
    "lastActive": "Online"
  },
  "messages": [
    {
      "id": 1,
      "text": "Halo, saya butuh bantuan!",
      "sender": "customer",
      "status": "sent",
      "time": "10:27"
    },
    {
      "id": 2,
      "text": "Halo! Ada yang bisa dibantu?",
      "sender": "agent",
      "status": "sent",
      "time": "10:28"
    }
  ]
}
```

---

## 💡 How Chat List Gets Data

### Step-by-Step Trace

#### 1. User Opens Dashboard
```tsx
// app/dashboard-admin/page.tsx
function Dashboard() {
  const [chats, setChats] = useState<Chat[]>([]);  // ← Empty initially

  useEffect(() => {
    loadChats();  // ← Called on mount
  }, []);
}
```

#### 2. loadChats() Executes
```tsx
const loadChats = async () => {
  // API call to backend
  const chatList = await chatApi.getAllChats();
  // chatList = [{id:1, name:"John"}, {id:2, name:"Sarah"}]

  // Get full details
  const fullChats = await Promise.all(
    chatList.map(item => chatApi.getChatDetail(item.id))
  );
  // fullChats = [{id:1, name:"John", messages:[...]}, ...]

  setChats(fullChats);  // ← Update state with REAL data
};
```

#### 3. State Update Triggers Re-render
```tsx
<ChatList
  chats={chats}  // ← Now has real data from database!
/>
```

#### 4. ChatList Renders Real Data
```tsx
// components/chat/chat-list.tsx
export default function ChatList({ chats = [] }) {
  return (
    <div>
      {chats.map(chat => (  // ← Loops through REAL chats
        <div key={chat.id}>
          {chat.name}         // ← "John Doe" from WhatsApp
          {chat.messages[0].text}  // ← "Halo, saya butuh bantuan!"
        </div>
      ))}
    </div>
  );
}
```

---

## 🚫 What's NOT in the Code Anymore

### ❌ Removed: Dummy Initial Chats
```tsx
// ❌ OLD - REMOVED
const initialChats: Chat[] = [
  {
    id: 1,
    name: "Test Customer",
    messages: [...]
  }
];
```

### ✅ New: Real Data from API
```tsx
// ✅ NEW - CURRENT
const [chats, setChats] = useState<Chat[]>([]);  // Empty initially
const loadChats = async () => {
  const data = await chatApi.getAllChats();  // From database!
  setChats(data);
};
```

---

## 🔄 Auto-Refresh Mechanism

### Every 5 Seconds
```tsx
useEffect(() => {
  loadChats();  // Initial load

  const interval = setInterval(() => {
    loadChats();  // Refresh every 5s
  }, 5000);

  return () => clearInterval(interval);  // Cleanup
}, [loadChats]);
```

### What Happens Every 5 Seconds:
```
1. Frontend: GET /chats/
2. Backend: Query database for latest chats
3. Frontend receives updated list
4. For each chat: GET /chats/{id}
5. Backend: Query messages for each chat
6. Frontend receives updated messages
7. State updates → UI re-renders
8. User sees latest data!
```

**Result:** New WhatsApp messages appear automatically without manual refresh!

---

## 📊 Data Sources Summary

| Component | Data Source | Update Frequency |
|-----------|-------------|------------------|
| ChatList | `chats` prop from parent | When parent re-renders |
| Admin Dashboard | `chatApi.getAllChats()` | Every 5 seconds |
| Agent Dashboard | `chatApi.getAllChats()` | Every 5 seconds |
| Chat Messages | `chatApi.getChatDetail(id)` | Every 5 seconds |
| Customer Info | `chat.profile` from API | Every 5 seconds |

**ALL sources:** PostgreSQL Database ← WhatsApp Webhook

---

## ✅ Verification Checklist

### Verify No Dummy Data:
```bash
# Check admin dashboard
grep -n "initialChats\|const.*=.*\[{" app/dashboard-admin/page.tsx
# Should return: No matches

# Check agent dashboard
grep -n "initialChats\|const.*=.*\[{" app/dashboard-agent/page.tsx
# Should return: No matches

# Check chat-list component
grep -n "initialChats\|const.*=.*\[{" components/chat/chat-list.tsx
# Should return: No matches
```

### Verify API Integration:
```bash
# Admin dashboard uses API
grep "chatApi" app/dashboard-admin/page.tsx
# Should show: getAllChats, getChatDetail, sendMessage, etc.

# Agent dashboard uses API
grep "chatApi" app/dashboard-agent/page.tsx
# Should show: getAllChats, getChatDetail, sendMessage, etc.
```

### Verify Real Data Flow:
```bash
# Test: Send WhatsApp message
curl -X POST http://localhost:8000/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "from": "+6281234567890@c.us",
      "from_name": "Test Customer",
      "text": {"body": "Hello from WhatsApp!"}
    }]
  }'

# Check database
curl http://localhost:8000/chats/

# Open dashboard - should see "Test Customer" in chat list!
```

---

## 🎯 Summary

### Before (Old):
```tsx
const initialChats = [{id:1, name:"Dummy"}];  // ❌ Hardcoded
<ChatList chats={initialChats} />
```

### After (Current):
```tsx
const [chats, setChats] = useState([]);  // ✅ Empty initially
useEffect(() => {
  const data = await chatApi.getAllChats();  // ✅ From database
  setChats(data);
}, []);
<ChatList chats={chats} />  // ✅ Real data!
```

---

**🎉 100% REAL DATA - NO DUMMY DATA ANYWHERE!**
