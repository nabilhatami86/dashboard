# ✅ Webhook Ready - Siap Test!

## 🎯 Status: WEBHOOK AKTIF!

### ✅ Yang Sudah Setup:

1. **Backend** ✅ - Running di `localhost:8000`
2. **Database** ✅ - Connected
3. **ngrok** ✅ - `https://d79ed692219b.ngrok-free.app`
4. **Webhook di WHAPI** ✅ - **CONFIGURED!**
   ```
   URL: https://d79ed692219b.ngrok-free.app/webhook/whapi
   Events: messages (POST)
   Status: ACTIVE
   ```

---

## 🧪 TEST WHATSAPP SEKARANG!

### Nomor Bot WhatsApp:
```
+62 877 3162 4016
```

### Kirim Message:
```
Halo Admin, saya butuh bantuan!
```

---

## 📊 Monitor di 3 Tempat:

### 1. ngrok Web Interface (PENTING!)
**URL:** `http://127.0.0.1:4040`

**Yang harus terlihat:**
```
POST /webhook/whapi    200 OK    [timestamp]
```

Click request untuk lihat detail:
- Request body: WhatsApp message payload
- Response: {"status":"ok","chat_id":X}

### 2. Backend Logs
Di terminal backend:
```
INFO: Received webhook data: {'messages': [...]}
INFO: Created new chat for 628XXX@c.us
INFO: Saved customer message to chat 7
INFO: Saved bot reply to chat 7
```

### 3. Dashboard
**URL:** `http://localhost:3000/login`
**Login:** `admin` / `admin123`

**Wait 5 detik** (auto-refresh)

**Harus muncul:**
- Chat list shows your name
- Badge: "WhatsApp"
- Last message preview
- Unread count

---

## 🔄 Complete Flow Test

### Test 1: WhatsApp → Dashboard

1. **Kirim WhatsApp:** "Halo Admin!"
2. **Check ngrok UI:** Request muncul ✅
3. **Check backend:** Log "Received webhook data" ✅
4. **Check dashboard:** Chat muncul dalam 5s ✅
5. **Check WhatsApp:** Bot auto-reply (jika mode BOT) ✅

### Test 2: Dashboard → WhatsApp

1. **Buka dashboard:** Login admin/admin123
2. **Click chat** dari WhatsApp
3. **Type reply:** "Halo! Ada yang bisa kami bantu?"
4. **Click Send**
5. **Check WhatsApp:** Reply muncul di HP customer ✅

### Test 3: Two-Way Communication

1. **Customer reply di WhatsApp:** "Saya mau tanya produk"
2. **Dashboard refresh (5s):** Message muncul ✅
3. **Agent reply dari dashboard:** "Silakan, produk apa?"
4. **Customer terima di WhatsApp:** Reply sampai ✅

---

## 🐛 Troubleshooting

### Jika Message TIDAK Masuk:

#### Check 1: ngrok Web UI
Buka `http://127.0.0.1:4040`

**Tidak ada request?**
- ❌ Bypass browser warning belum dilakukan
- ❌ Webhook URL salah
- Fix: Visit `https://d79ed692219b.ngrok-free.app` → Click "Visit Site"

**Ada request tapi error?**
- Check status code
- Check response body
- Check backend logs

#### Check 2: Backend Logs
Terminal backend tidak ada log "Received webhook data"?
- Backend mungkin crash
- Restart: `python3 -m uvicorn app.main:app --reload`

#### Check 3: Database
```bash
curl http://localhost:8000/chats/ | python3 -m json.tool
```

Tidak ada chat baru?
- Webhook tidak sampai ke backend
- Check ngrok Web UI

---

## 📱 Bot Number Info

**WhatsApp Number:** +62 877 3162 4016
**Channel Name:** SHAZAM-FLR7A
**API Status:** Authorized ✅
**Plan:** Trial (0 days remaining)
**Limits:**
- Messages: 3/150
- Chats: 2/5
- Requests: 9/1k

---

## 🎯 Expected Timeline

```
T=0s    : Customer kirim WhatsApp
T=0.5s  : WHAPI receives
T=1s    : WHAPI POST ke ngrok webhook
T=1.5s  : Backend receives & saves to DB
T=2s    : Bot generates reply (if BOT mode)
T=2.5s  : Bot reply sent to WhatsApp
T=3s    : Customer receives bot reply
T=5s    : Dashboard auto-refresh
T=5.5s  : ✅ Chat muncul di Dashboard!
```

---

## ✅ Quick Verification Commands

### Check Webhook Config
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -c "
import requests, os
from dotenv import load_dotenv
load_dotenv()
r = requests.get('https://gate.whapi.cloud/settings',
    headers={'Authorization': f'Bearer {os.getenv(\"WHAPI_TOKEN\")}'})
print('Webhooks:', r.json().get('webhooks'))
"
```

### Check Database
```bash
curl http://localhost:8000/chats/ | python3 -m json.tool
```

### Test Local Webhook
```bash
curl -X POST http://localhost:8000/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"from":"test@c.us","text":{"body":"test"}}]}'
```

---

## 🚀 READY TO TEST!

**Checklist:**
- [x] Backend running
- [x] ngrok running
- [x] Webhook configured in WHAPI
- [x] Browser warning bypassed (visit ngrok URL)
- [ ] **Send WhatsApp message to +62 877 3162 4016**
- [ ] **Monitor ngrok Web UI: http://127.0.0.1:4040**
- [ ] **Check dashboard: http://localhost:3000**

---

**Kirim WhatsApp sekarang dan lihat hasilnya!** 🎉
