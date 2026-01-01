# 🔧 Setup WhatsApp Webhook - Step by Step

## ❌ Masalah: WhatsApp Message Tidak Masuk ke Dashboard

### Penyebab:
WhatsApp API (WHAPI.cloud) **tidak bisa** mengirim webhook ke `http://localhost:8000` karena:
- Localhost hanya accessible dari komputer Anda
- WHAPI.cloud butuh URL yang bisa diakses dari internet

### Bukti Backend Bekerja:
✅ Test webhook lokal berhasil (chat ID 5 created)
✅ Database menyimpan chat & messages
✅ Bot auto-reply bekerja

**Jadi masalahnya bukan di code, tapi di webhook configuration!**

---

## ✅ Solusi: Expose Localhost dengan ngrok

### Option 1: Menggunakan ngrok (Recommended)

#### 1. Install ngrok
```bash
# macOS
brew install ngrok

# Atau download manual dari https://ngrok.com/download
```

#### 2. Sign up untuk ngrok (GRATIS)
- Buka: https://dashboard.ngrok.com/signup
- Sign up gratis
- Copy authtoken Anda

#### 3. Setup authtoken
```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

#### 4. Start Backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -m uvicorn app.main:app --reload
```

Backend akan running di `http://localhost:8000`

#### 5. Start ngrok (Di terminal baru)
```bash
ngrok http 8000
```

Output akan seperti ini:
```
Session Status                online
Account                       your-email@gmail.com (Plan: Free)
Version                       3.x.x
Region                        Asia Pacific (ap)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123.ngrok.io -> http://localhost:8000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**COPY URL ini:** `https://abc123.ngrok.io`

#### 6. Set Webhook di WHAPI Dashboard

1. Login ke https://whapi.cloud (atau dashboard WhatsApp API provider Anda)
2. Pilih channel WhatsApp Anda
3. Pergi ke **Webhooks** atau **Settings**
4. Set Webhook URL ke:
   ```
   https://abc123.ngrok.io/webhook/whapi
   ```
   (Ganti `abc123` dengan URL ngrok Anda)
5. Save

#### 7. Test dengan WhatsApp Real!

Sekarang kirim message dari WhatsApp Anda ke nomor bot:
```
Halo, saya butuh bantuan!
```

**Apa yang terjadi:**
```
WhatsApp Customer sends message
        ↓
WHAPI.cloud receives
        ↓
WHAPI sends POST to https://abc123.ngrok.io/webhook/whapi
        ↓
ngrok forwards to http://localhost:8000/webhook/whapi
        ↓
Backend saves to database
        ↓
Bot auto-replies
        ↓
Dashboard auto-refresh (5s)
        ↓
Chat appears in dashboard!
```

#### 8. Monitor Webhook Calls

Buka ngrok web interface: http://127.0.0.1:4040

Di sini Anda bisa lihat:
- ✅ Semua HTTP requests yang masuk
- ✅ Request body dari WHAPI
- ✅ Response dari backend
- ✅ Debug jika ada error

---

### Option 2: Deploy ke Server (Production)

Untuk production, Anda perlu deploy backend ke server dengan public URL:

#### A. Deploy ke Railway (Free)
1. Signup di https://railway.app
2. Connect GitHub repo
3. Deploy backend
4. Railway akan kasih public URL: `https://your-app.railway.app`
5. Set webhook di WHAPI ke: `https://your-app.railway.app/webhook/whapi`

#### B. Deploy ke Render (Free)
1. Signup di https://render.com
2. New → Web Service
3. Connect GitHub repo
4. Deploy
5. Get public URL: `https://your-app.onrender.com`
6. Set webhook: `https://your-app.onrender.com/webhook/whapi`

#### C. Deploy ke VPS (DigitalOcean, AWS, dll)
1. Setup server dengan public IP
2. Install Nginx sebagai reverse proxy
3. Setup SSL dengan Let's Encrypt
4. Point domain ke server
5. Webhook URL: `https://yourdomain.com/webhook/whapi`

---

## 🧪 Testing & Verification

### 1. Test ngrok URL
```bash
# Ganti dengan ngrok URL Anda
curl -X POST https://abc123.ngrok.io/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "from": "6281234567890@c.us",
      "from_name": "Test Customer",
      "text": {"body": "Test dari curl"}
    }]
  }'
```

Expected response:
```json
{
  "status": "ok",
  "mode": "bot",
  "chat_id": 6,
  "bot_replied": true
}
```

### 2. Check Backend Logs

Di terminal backend, Anda akan lihat:
```
INFO:     Received webhook data: {'messages': [...]}
INFO:     Created new chat for 6281234567890@c.us
INFO:     Saved customer message to chat 6
INFO:     Saved bot reply to chat 6
```

### 3. Check ngrok Web Interface

Buka http://127.0.0.1:4040, Anda akan lihat:
- Request dari WHAPI.cloud
- Request body (WhatsApp message payload)
- Response dari backend
- Status code

### 4. Check Database
```bash
curl http://localhost:8000/chats/ | python3 -m json.tool
```

Harus ada chat baru dengan nama dari WhatsApp.

### 5. Check Dashboard

1. Buka http://localhost:3000/login
2. Login: `admin` / `admin123`
3. ✅ Chat dari WhatsApp harus muncul dalam 5 detik!

---

## 🔍 Troubleshooting

### Problem: ngrok URL tidak bisa diakses

**Solution:**
```bash
# Check apakah ngrok masih running
ps aux | grep ngrok

# Restart ngrok
ngrok http 8000
```

### Problem: WHAPI tidak kirim webhook

**Check:**
1. Apakah webhook URL di WHAPI dashboard sudah benar?
2. Apakah URL pakai `https://` bukan `http://`?
3. Apakah ngrok masih running?
4. Test manual dengan curl ke ngrok URL

### Problem: Backend tidak terima webhook

**Check backend logs:**
```bash
# Di terminal backend, cari log:
INFO:     Received webhook data: ...
```

Jika tidak ada log, berarti WHAPI tidak kirim atau URL salah.

### Problem: Bot tidak reply

**Check:**
1. Chat mode di database: harus `bot` bukan `agent`
2. Backend log: `Saved bot reply to chat X`
3. WHAPI_TOKEN di `.env` harus valid

```bash
# Check chat mode
curl http://localhost:8000/chats/1 | python3 -m json.tool | grep mode
```

### Problem: Chat tidak muncul di dashboard

**Check:**
1. Frontend sudah login?
2. Frontend URL correct: `NEXT_PUBLIC_API_URL=http://localhost:8000`
3. Auto-refresh working (console log setiap 5s)
4. Database ada chat-nya (curl /chats/)

---

## 📊 Complete Setup Summary

### Terminal 1: Backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -m uvicorn app.main:app --reload
```

### Terminal 2: ngrok
```bash
ngrok http 8000
# Copy URL: https://abc123.ngrok.io
```

### Terminal 3: Frontend
```bash
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
npm run dev
```

### Browser 1: WHAPI Dashboard
- URL: https://whapi.cloud
- Set webhook: `https://abc123.ngrok.io/webhook/whapi`

### Browser 2: ngrok Monitor
- URL: http://127.0.0.1:4040
- Monitor requests real-time

### Browser 3: Your Dashboard
- URL: http://localhost:3000/login
- Login: admin / admin123
- See WhatsApp chats!

---

## 🎯 Expected Flow After Setup

```
Customer WhatsApp: "Halo!"
        ↓
WHAPI.cloud detects message
        ↓ (webhook)
POST https://abc123.ngrok.io/webhook/whapi
        ↓
ngrok forwards to localhost:8000
        ↓
Backend: Webhook handler receives
        ↓
Backend: Save to PostgreSQL
        ↓
Backend: Bot generates reply
        ↓
Backend: Save bot reply to PostgreSQL
        ↓
Backend: Send to WHAPI.cloud
        ↓
Customer receives bot reply on WhatsApp
        ↓
Dashboard auto-refresh (5s)
        ↓
Admin sees conversation in dashboard!
```

---

## 💡 Alternative: Test Without Real WhatsApp

Jika Anda belum setup ngrok atau WHAPI, Anda masih bisa test system dengan:

### Test Script (Sudah dibuat)
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 test_webhook.py
```

Script ini akan:
1. ✅ Simulate WhatsApp message
2. ✅ POST ke webhook endpoint
3. ✅ Create chat di database
4. ✅ Save messages
5. ✅ Trigger bot reply

**Kemudian buka dashboard:**
1. http://localhost:3000/login
2. Login: admin / admin123
3. ✅ Chat "Test Customer" akan muncul!

---

## 🚀 Quick Start Commands

```bash
# 1. Install ngrok
brew install ngrok

# 2. Sign up & get authtoken dari https://dashboard.ngrok.com
ngrok config add-authtoken YOUR_TOKEN

# 3. Start backend (terminal 1)
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -m uvicorn app.main:app --reload

# 4. Start ngrok (terminal 2)
ngrok http 8000
# COPY URL: https://abc123.ngrok.io

# 5. Start frontend (terminal 3)
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
npm run dev

# 6. Set webhook di WHAPI dashboard
# URL: https://abc123.ngrok.io/webhook/whapi

# 7. Test dengan WhatsApp!
# Kirim message ke bot number

# 8. Open dashboard
# http://localhost:3000/login
# Login: admin / admin123
```

---

**🎉 Setelah setup ngrok, WhatsApp message PASTI masuk ke dashboard!**
