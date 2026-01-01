# 💬 WhatsApp Integration dengan Dashboard

## Overview
Sistem chat dashboard sekarang **fully integrated** dengan WhatsApp! Pesan dari WhatsApp otomatis tersimpan di database dan muncul real-time di dashboard. Agent dapat membalas langsung dari dashboard dan pesan terkirim ke WhatsApp customer.

---

## 🎯 Fitur WhatsApp Integration

### Incoming Messages (WhatsApp → Dashboard) ✅
- ✅ Webhook menerima pesan dari WhatsApp
- ✅ Auto-create chat baru untuk nomor baru
- ✅ Simpan messages ke database
- ✅ Update chat status (online, unread count)
- ✅ Bot auto-reply untuk mode BOT
- ✅ Tidak reply jika mode AGENT/PAUSED/CLOSED
- ✅ Dashboard auto-refresh dan tampilkan chat baru

### Outgoing Messages (Dashboard → WhatsApp) ✅
- ✅ Agent kirim pesan dari dashboard
- ✅ Pesan otomatis terkirim ke WhatsApp
- ✅ Messages tersimpan di database
- ✅ Error handling jika WhatsApp API gagal

---

## 🔄 Flow Diagram

### Customer Sends Message
```
WhatsApp Customer sends message
        ↓
POST /webhook/whapi (webhook receives)
        ↓
Get/Create Chat in database
        ↓
Save customer message to database
        ↓
Check chat mode:
  - BOT: Generate & send bot reply
  - AGENT: No reply (wait for agent)
  - PAUSED: No reply
  - CLOSED: No reply
        ↓
Dashboard auto-refreshes (5s)
        ↓
Admin/Agent sees message in dashboard
```

### Agent Replies from Dashboard
```
Agent types message in dashboard
        ↓
Click Send
        ↓
POST /chats/messages
        ↓
Save message to database
        ↓
Check if chat is WhatsApp
        ↓
YES: Send to WhatsApp via send_text()
        ↓
Customer receives message on WhatsApp
        ↓
Dashboard shows message instantly
```

---

## 🛠️ Implementation Details

### Webhook Integration
**File:** [app/whapi/webhook.py](backend-dashboard-python/app/whapi/webhook.py)

**Key Functions:**

#### 1. Get or Create Chat
```python
def get_or_create_chat(db: Session, phone: str, name: str = None) -> Chat:
    # Try to find existing chat
    chat = db.query(Chat).filter(Chat.customer_phone == phone).first()

    if chat:
        # Update existing
        chat.online = True
        chat.last_message_at = datetime.now()
        return chat

    # Create new chat
    new_chat = Chat(
        customer_name=name or phone,
        customer_phone=phone,
        channel=ChatChannel.whatsapp,
        mode=ChatMode.bot,  # Start in bot mode
        online=True,
        unread_count=0,
    )
    db.add(new_chat)
    db.commit()
    return new_chat
```

#### 2. Save Customer Message
```python
def save_customer_message(db: Session, chat: Chat, text: str) -> Message:
    message = Message(
        chat_id=chat.id,
        text=text,
        sender=MessageSender.customer,
        status=MessageStatus.sent,
    )
    db.add(message)

    # Increment unread
    chat.unread_count += 1
    db.commit()
    return message
```

#### 3. Webhook Handler
```python
@router.post("/webhook/whapi")
async def whapi_webhook(request: Request, db: Session = Depends(get_db)):
    # Parse webhook data
    data = await request.json()
    sender = data["messages"][0]["from"]
    text = data["messages"][0]["text"]["body"]

    # Get/create chat
    chat = get_or_create_chat(db, sender)

    # Save customer message
    save_customer_message(db, chat, text)

    # Check mode and reply if BOT mode
    if chat.mode == ChatMode.bot:
        reply = handle_bot(sender, text)
        if reply:
            save_bot_reply(db, chat, reply)
            send_text(sender, reply)  # Send to WhatsApp

    return {"status": "ok", "chat_id": chat.id}
```

### Send Message Integration
**File:** [app/controller/chat_controller.py](backend-dashboard-python/app/controller/chat_controller.py:148-202)

```python
def send_message(data: MessageCreate, db: Session) -> MessageResponse:
    # ... save message to database ...

    # If agent message and WhatsApp chat, send to WhatsApp
    if data.sender == "agent" and chat.channel.value == "WhatsApp":
        try:
            result = send_text(chat.customer_phone, data.text)
            if result.get("ok"):
                logger.info(f"Message sent to WhatsApp")
        except Exception as e:
            logger.exception(f"WhatsApp send failed")
            # Don't fail request if WhatsApp fails

    return message
```

---

## 🔧 Setup WhatsApp API

### 1. Get WHAPI Credentials
Anda perlu mendaftar di [Whapi.Cloud](https://whapi.cloud/) atau WhatsApp Business API provider lain.

### 2. Configure Environment Variables
**File:** `.env` di backend

```env
# WhatsApp API Configuration
WHAPI_BASE_URL=https://gate.whapi.cloud
WHAPI_TOKEN=your_whapi_token_here
WHAPI_ADMINS=+6281234567890,+6289876543210
```

### 3. Set Webhook URL
Di dashboard WHAPI, set webhook URL ke:
```
https://your-domain.com/webhook/whapi
```

Untuk development local, gunakan ngrok:
```bash
ngrok http 8000
# Copy ngrok URL and set webhook to:
# https://abc123.ngrok.io/webhook/whapi
```

---

## 📱 Testing WhatsApp Integration

### Test 1: Incoming Message
1. Start backend server
2. Send message dari WhatsApp ke nomor bot Anda
3. Check database:
   ```bash
   # Check if chat created
   curl http://localhost:8000/chats/

   # Check if message saved
   curl http://localhost:8000/chats/1
   ```
4. Open dashboard - chat should appear!

### Test 2: Bot Auto-Reply
1. Send message: "Halo"
2. Bot should auto-reply
3. Check dashboard - both messages should appear

### Test 3: Assign to Agent
1. In dashboard, click chat
2. Click "Assign to Agent"
3. Send message from WhatsApp
4. Bot should NOT reply
5. Agent can see message in dashboard

### Test 4: Agent Reply
1. Agent types message in dashboard
2. Click send
3. Customer should receive on WhatsApp
4. Check WhatsApp - message should appear

---

## 🔍 Webhook Payload Example

### WhatsApp Incoming Message
```json
{
  "messages": [
    {
      "from": "6281234567890@c.us",
      "from_name": "John Doe",
      "pushname": "John",
      "text": {
        "body": "Halo, saya butuh bantuan!"
      },
      "timestamp": 1704123456
    }
  ]
}
```

### Webhook Processing
```
1. Extract: phone = "6281234567890@c.us"
2. Extract: name = "John Doe"
3. Extract: text = "Halo, saya butuh bantuan!"
4. Get/Create Chat for this phone
5. Save message to database
6. Check mode: BOT
7. Generate bot reply
8. Save bot reply to database
9. Send bot reply to WhatsApp
```

---

## 🎨 Dashboard Features

### Chat List Shows WhatsApp Chats
- Phone number as identifier
- Name from WhatsApp contact
- Channel badge shows "WhatsApp"
- Unread count from database
- Online status

### Agent Can:
- View all messages from WhatsApp
- Send replies that go to WhatsApp
- Assign chat to themselves
- Pause/Close chat
- See customer phone number

### Admin Can:
- See all WhatsApp chats
- Assign chats to agents
- Switch between BOT/AGENT mode
- Monitor bot performance

---

## 🔐 Chat Modes Explained

### BOT Mode
```
Customer sends message
  ↓
Bot generates auto-reply
  ↓
Reply sent to WhatsApp
  ↓
All auto-handled
```

### AGENT Mode
```
Customer sends message
  ↓
NO bot reply
  ↓
Agent sees in dashboard
  ↓
Agent types reply
  ↓
Reply sent to WhatsApp
```

### PAUSED Mode
```
Customer sends message
  ↓
NO bot reply
  ↓
NO agent notification
  ↓
Message saved but no action
```

### CLOSED Mode
```
Customer sends message
  ↓
Message saved
  ↓
No reply, no notification
  ↓
Chat considered closed
```

---

## 🐛 Troubleshooting

### Messages Not Appearing in Dashboard
**Problem:** WhatsApp messages tidak muncul di dashboard

**Check:**
1. Webhook configured correctly?
   ```bash
   curl -X POST http://localhost:8000/webhook/whapi \
     -H "Content-Type: application/json" \
     -d '{"messages":[{"from":"123@c.us","text":{"body":"test"}}]}'
   ```
2. Check backend logs for webhook errors
3. Verify database has new chats:
   ```bash
   curl http://localhost:8000/chats/
   ```

### Bot Not Replying
**Problem:** Bot tidak auto-reply

**Check:**
1. Chat mode is BOT (not AGENT/PAUSED)
2. `handle_bot()` function working
3. WhatsApp API credentials valid
4. Check backend logs

### Agent Reply Not Sent to WhatsApp
**Problem:** Message saved di dashboard tapi tidak sampai ke WhatsApp

**Check:**
1. WHAPI_TOKEN configured correctly
2. WHAPI_BASE_URL correct
3. Phone number format correct (+6281234567890@c.us)
4. Check backend logs for WhatsApp API errors

### Webhook Not Receiving Messages
**Problem:** Webhook tidak dipanggil

**Solutions:**
1. For local dev, use ngrok:
   ```bash
   ngrok http 8000
   ```
2. Set webhook URL di WHAPI dashboard
3. Test webhook manually:
   ```bash
   curl -X POST https://your-ngrok-url.ngrok.io/webhook/whapi \
     -H "Content-Type: application/json" \
     -d '{"messages":[{"from":"test@c.us","text":{"body":"hi"}}]}'
   ```

---

## 📊 Database Schema for WhatsApp

### Chat Table
```sql
-- Example WhatsApp chat
INSERT INTO chats (
    customer_name,
    customer_phone,        -- WhatsApp number
    channel,
    mode,
    online,
    unread_count
) VALUES (
    'John Doe',
    '+6281234567890@c.us', -- WhatsApp format
    'WhatsApp',
    'bot',
    true,
    2
);
```

### Message Table
```sql
-- Customer message
INSERT INTO messages (
    chat_id,
    text,
    sender,
    status
) VALUES (
    1,
    'Halo, saya butuh bantuan!',
    'customer',
    'sent'
);

-- Bot/Agent reply
INSERT INTO messages (
    chat_id,
    text,
    sender,
    status,
    agent_id
) VALUES (
    1,
    'Halo! Ada yang bisa kami bantu?',
    'agent',
    'sent',
    2  -- or NULL for bot
);
```

---

## 🚀 Advanced Features

### Auto-Assign by Keywords
```python
# In webhook.py
if "urgent" in text.lower():
    # Find available agent
    agent = db.query(User).filter(User.role == "agent").first()
    chat.mode = ChatMode.agent
    chat.assigned_agent_id = agent.id
    db.commit()
```

### Business Hours Check
```python
from datetime import datetime

def is_business_hours():
    now = datetime.now()
    # Mon-Fri, 9AM-6PM
    return (now.weekday() < 5 and
            9 <= now.hour < 18)

# In webhook
if not is_business_hours():
    reply = "Terima kasih. Kami buka Senin-Jumat 9:00-18:00"
```

### Customer Info Enrichment
```python
def enrich_customer_info(chat, msg_data):
    # Extract from WhatsApp payload
    if msg_data.get("profile_picture"):
        chat.customer_avatar = msg_data["profile_picture"]

    if msg_data.get("status"):
        chat.customer_status = msg_data["status"]

    db.commit()
```

---

## 📈 Monitoring & Analytics

### Useful Queries
```sql
-- Total WhatsApp chats today
SELECT COUNT(*) FROM chats
WHERE channel = 'WhatsApp'
AND created_at >= CURRENT_DATE;

-- Active chats (last 24h)
SELECT COUNT(*) FROM chats
WHERE channel = 'WhatsApp'
AND last_message_at >= NOW() - INTERVAL '24 hours';

-- Bot vs Agent messages
SELECT sender, COUNT(*) FROM messages
GROUP BY sender;

-- Response time
SELECT AVG(
    EXTRACT(EPOCH FROM (agent_msg.created_at - customer_msg.created_at))
) AS avg_response_seconds
FROM messages customer_msg
JOIN messages agent_msg ON agent_msg.chat_id = customer_msg.chat_id
WHERE customer_msg.sender = 'customer'
AND agent_msg.sender = 'agent'
AND agent_msg.created_at > customer_msg.created_at;
```

---

## ✨ Next Steps

### Immediate
1. ✅ **Done:** WhatsApp → Database
2. ✅ **Done:** Database → WhatsApp
3. 🔄 **Todo:** Handle media messages (images, files)
4. 🔄 **Todo:** WhatsApp status updates
5. 🔄 **Todo:** Typing indicators

### Advanced
- Group chat support
- Broadcast messages
- Message templates
- Rich media (location, contact cards)
- Read receipts
- Message reactions

---

**Happy WhatsApp Integration! 💬📱**
