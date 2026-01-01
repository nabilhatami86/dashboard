# 📱 Test WhatsApp → Dashboard → WhatsApp (Complete Flow)

## 🎯 Yang Anda Ingin Test:

```
Customer kirim WhatsApp message
        ↓
Webhook receives (via ngrok)
        ↓
Backend save ke Database
        ↓
Dashboard menampilkan chat (auto-refresh 5s)
        ↓
Admin/Agent bisa lihat & reply dari Dashboard
        ↓
Reply terkirim ke WhatsApp Customer
```

---

## 📋 Setup Webhook (5 Menit)

### Step 1: Pastikan Semua Running

#### Terminal 1: Backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -m uvicorn app.main:app --reload
```

**Expected output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

#### Terminal 2: ngrok
```bash
ngrok http 8000
```

**Expected output:**
```
Forwarding    https://d79ed692219b.ngrok-free.app -> http://localhost:8000
```

**COPY URL ini:** `https://d79ed692219b.ngrok-free.app`

#### Terminal 3: Frontend
```bash
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
npm run dev
```

**Expected output:**
```
ready - started server on 0.0.0.0:3000
```

---

### Step 2: Bypass ngrok Browser Warning

**Penting:** ngrok free tier butuh bypass browser warning dulu!

1. **Buka browser**
2. **Visit:** `https://d79ed692219b.ngrok-free.app`
3. Akan muncul halaman warning
4. **Click "Visit Site"**
5. ✅ Setelah ini webhook bisa diakses dari internet

---

### Step 3: Set Webhook di WHAPI.cloud

#### A. Login ke WHAPI Dashboard
- Buka: https://whapi.cloud
- Login dengan akun Anda

#### B. Pilih Channel WhatsApp Anda
- Di dashboard, pilih channel/nomor bot WhatsApp yang aktif

#### C. Set Webhook URL
- Cari menu **"Webhooks"** atau **"Settings"**
- Set **Webhook URL** ke:
  ```
  https://d79ed692219b.ngrok-free.app/webhook/whapi
  ```
- **Save** configuration

#### D. Test Webhook (Optional)
Beberapa provider punya tombol "Test Webhook" - click untuk test koneksi.

---

## 🧪 Test Complete Flow

### Test 1: WhatsApp → Database

1. **Dari HP Anda, kirim WhatsApp message** ke nomor bot:
   ```
   Halo Admin, saya butuh bantuan!
   ```

2. **Monitor ngrok Web Interface:**
   - Buka: `http://127.0.0.1:4040`
   - Harus ada **POST /webhook/whapi** request
   - Check request body - harus ada message Anda

3. **Check Backend Logs:**
   Di terminal backend, harus muncul:
   ```
   INFO: Received webhook data: {'messages': [...]}
   INFO: Created new chat for 628XXXXXXXXX@c.us
   INFO: Saved customer message to chat 7
   INFO: Saved bot reply to chat 7
   ```

4. **Check Database:**
   ```bash
   curl http://localhost:8000/chats/ | python3 -m json.tool
   ```
   Harus ada chat baru dengan nama/nomor HP Anda.

5. **Check di WhatsApp:**
   - Bot harus auto-reply (jika mode BOT)
   - Reply muncul di WhatsApp Anda

---

### Test 2: Database → Dashboard

1. **Buka Dashboard:**
   - URL: `http://localhost:3000/login`
   - Login: `admin` / `admin123`

2. **Wait 5 detik** (auto-refresh)

3. **✅ Chat dari WhatsApp harus muncul** di chat list:
   - Nama: Nama Anda dari WhatsApp contact
   - Last message: "Halo Admin, saya butuh bantuan!"
   - Badge: "WhatsApp"
   - Unread count: 1 (atau 2 jika ada bot reply)

4. **Click chat** untuk buka conversation

5. **Lihat messages:**
   - Message Anda (customer)
   - Bot reply (jika ada)

---

### Test 3: Dashboard → WhatsApp (Agent Reply)

1. **Di Dashboard, select chat** dari WhatsApp

2. **Type message di input box:**
   ```
   Halo! Tim kami siap membantu. Ada yang bisa kami bantu?
   ```

3. **Click Send button**

4. **Check Backend Logs:**
   ```
   INFO: Message sent to WhatsApp for chat 7
   ```

5. **Check WhatsApp HP Anda:**
   - ✅ Message dari dashboard **harus muncul di WhatsApp**
   - Sender: Nomor bot

6. **Check Dashboard:**
   - Message langsung muncul di conversation
   - No delay (optimistic update)

---

### Test 4: Two-Way Communication

1. **Reply dari WhatsApp:**
   ```
   Terima kasih! Saya ingin tanya tentang produk.
   ```

2. **Monitor ngrok:** `http://127.0.0.1:4040`
   - Harus ada POST request baru

3. **Dashboard auto-refresh (5s):**
   - ✅ Reply Anda muncul di dashboard

4. **Agent reply dari Dashboard:**
   ```
   Silakan, produk apa yang ingin ditanyakan?
   ```

5. **Check WhatsApp:**
   - ✅ Reply dari agent muncul

**REPEAT** - Bolak-balik WhatsApp ↔ Dashboard should work seamlessly!

---

## 🔍 Monitoring & Debugging

### Monitor Real-time di ngrok Web Interface

**URL:** `http://127.0.0.1:4040`

**Anda bisa lihat:**
- ✅ Semua webhook POST requests dari WHAPI
- ✅ Request headers
- ✅ Request body (WhatsApp message payload)
- ✅ Response dari backend
- ✅ Response time
- ✅ Status codes

**Fitur:**
- Click request untuk inspect detail
- Replay request untuk testing
- Filter requests

### Backend Logs

Di terminal backend, monitor:
```
INFO: Received webhook data: ...
INFO: Created new chat for ...
INFO: Saved customer message to chat X
INFO: Saved bot reply to chat X
INFO: Message sent to WhatsApp for chat X
```

### Database Monitor

Check database real-time:
```bash
# List all chats
curl http://localhost:8000/chats/ | python3 -m json.tool

# Get specific chat
curl http://localhost:8000/chats/7 | python3 -m json.tool
```

### Frontend Console

1. Buka dashboard: `http://localhost:3000`
2. F12 → Console
3. Monitor API calls setiap 5 detik
4. Check for errors

---

## 📊 Expected Flow Timeline

```
T=0s    : Customer kirim WhatsApp "Halo"
T=0.5s  : WHAPI.cloud receives message
T=1s    : WHAPI sends POST to ngrok webhook
T=1.5s  : Backend receives, saves to DB
T=2s    : Bot generates reply
T=2.5s  : Bot reply saved to DB
T=3s    : Bot reply sent to WhatsApp
T=3.5s  : Customer receives bot reply on WhatsApp
T=5s    : Dashboard auto-refresh
T=5.5s  : ✅ Chat muncul di Dashboard Admin!
```

**Agent reply:**
```
T=0s    : Agent type & send dari Dashboard
T=0.5s  : Backend saves to DB
T=1s    : Backend calls WHAPI send_text()
T=1.5s  : WHAPI delivers to WhatsApp
T=2s    : ✅ Customer receives di WhatsApp!
```

---

## 🐛 Troubleshooting

### Problem 1: Message tidak sampai ke Backend

**Symptoms:**
- Kirim WhatsApp, tidak ada di ngrok logs
- Tidak ada di backend logs
- Tidak ada di database

**Check:**
1. Webhook URL di WHAPI benar?
   - Harus: `https://d79ed692219b.ngrok-free.app/webhook/whapi`
2. ngrok masih running?
   - Check: `ps aux | grep ngrok`
3. Sudah bypass browser warning?
   - Visit URL di browser, click "Visit Site"

**Fix:**
```bash
# Check ngrok status
curl https://d79ed692219b.ngrok-free.app/

# Test webhook manual
curl -X POST https://d79ed692219b.ngrok-free.app/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"from":"test@c.us","text":{"body":"test"}}]}'
```

### Problem 2: Bot Tidak Reply

**Symptoms:**
- Message masuk ke database
- Tapi bot tidak reply ke WhatsApp

**Check:**
1. Chat mode = BOT?
   ```bash
   curl http://localhost:8000/chats/7 | grep mode
   ```
2. WHAPI_TOKEN di `.env` benar?
3. Backend logs ada error?

**Fix:**
```bash
# Change chat to BOT mode
curl -X PATCH http://localhost:8000/chats/7 \
  -H "Content-Type: application/json" \
  -d '{"mode":"bot"}'
```

### Problem 3: Chat Tidak Muncul di Dashboard

**Symptoms:**
- Data ada di database
- Tapi tidak muncul di dashboard

**Check:**
1. Frontend running? → `curl http://localhost:3000`
2. Sudah login? → Refresh page
3. Browser console errors? → F12
4. Wait 5 seconds untuk auto-refresh

**Fix:**
1. Hard refresh: Ctrl+Shift+R (Windows) atau Cmd+Shift+R (Mac)
2. Clear localStorage: F12 → Application → Local Storage → Clear
3. Re-login: admin / admin123

### Problem 4: Agent Reply Tidak Terkirim ke WhatsApp

**Symptoms:**
- Send dari dashboard berhasil
- Message muncul di dashboard
- Tapi tidak sampai ke WhatsApp

**Check:**
1. Backend logs ada "Message sent to WhatsApp"?
2. WHAPI_TOKEN valid?
3. Customer phone format benar? (harus ada @c.us)

**Fix:**
Check backend logs:
```bash
# Di terminal backend, cari:
INFO: Message sent to WhatsApp for chat 7
# Atau:
ERROR: Failed to send WhatsApp message: ...
```

---

## ✅ Success Checklist

Setelah setup, verify semua ini bekerja:

### WhatsApp → Database
- [ ] Kirim WhatsApp message
- [ ] Muncul di ngrok logs (`http://127.0.0.1:4040`)
- [ ] Backend log: "Received webhook data"
- [ ] Chat created di database
- [ ] Messages saved di database

### Database → Dashboard
- [ ] Buka dashboard: `http://localhost:3000/login`
- [ ] Login: admin / admin123
- [ ] Chat dari WhatsApp muncul di list
- [ ] Click chat → Messages tampil
- [ ] Unread count correct

### Dashboard → WhatsApp
- [ ] Type message di dashboard
- [ ] Click Send
- [ ] Message muncul di dashboard instant
- [ ] Backend log: "Message sent to WhatsApp"
- [ ] Customer terima di WhatsApp

### Bot Auto-Reply
- [ ] Send WhatsApp message
- [ ] Bot auto-reply (jika mode BOT)
- [ ] Bot reply muncul di WhatsApp
- [ ] Bot reply muncul di dashboard

---

## 🎯 Quick Test Commands

### Test Webhook dari Terminal
```bash
# Test dengan curl
curl -X POST https://d79ed692219b.ngrok-free.app/webhook/whapi \
  -H "Content-Type: application/json" \
  -H "User-Agent: WhatsApp/1.0" \
  -d '{
    "messages": [{
      "from": "628123456789@c.us",
      "from_name": "Test User",
      "text": {"body": "Test message"}
    }]
  }'

# Expected response:
# {"status":"ok","mode":"bot","chat_id":8,"bot_replied":true}
```

### Check Database
```bash
# List chats
curl http://localhost:8000/chats/ | python3 -m json.tool

# Get specific chat with messages
curl http://localhost:8000/chats/8 | python3 -m json.tool
```

### Test Dashboard API
```bash
# Test dari browser console:
# F12 → Console → Paste:
fetch('http://localhost:8000/chats/')
  .then(r => r.json())
  .then(data => console.log('Chats:', data))
```

---

## 📱 Complete Test Scenario

### Scenario: Customer Service Chat

1. **Customer (via WhatsApp):**
   ```
   Halo, saya mau tanya produk X
   ```

2. **Bot auto-reply:**
   ```
   Terima kasih. Kami akan membantu Anda segera.
   Ketik 'agent' untuk bicara dengan manusia.
   ```

3. **Customer:**
   ```
   agent
   ```

4. **Bot (no reply, switches to AGENT mode)**

5. **Admin sees in Dashboard:**
   - Chat list shows "Customer Name"
   - Badge: WhatsApp
   - Unread: 2
   - Last message: "agent"

6. **Admin assigns to Agent:**
   - Click "Assign to Agent"
   - Select agent name

7. **Agent Dashboard:**
   - Chat appears in agent's chat list
   - Agent sees full conversation

8. **Agent replies from Dashboard:**
   ```
   Halo! Saya Agent Sarah, siap membantu.
   Produk apa yang ingin ditanyakan?
   ```

9. **Customer receives on WhatsApp:**
   - Reply from bot number
   - Conversation continues...

10. **Two-way chat continues:**
    - Customer ↔ WhatsApp
    - Agent ↔ Dashboard
    - ✅ Seamless communication!

---

## 🚀 Ready to Test!

**Setup Checklist:**
- [x] Backend running: `localhost:8000`
- [x] ngrok running: `https://d79ed692219b.ngrok-free.app`
- [ ] Frontend running: `localhost:3000`
- [ ] Bypass ngrok warning (visit URL in browser)
- [ ] Set webhook di WHAPI.cloud
- [ ] Test kirim WhatsApp message!

**Total setup time:** ~5 menit

**After setup:** Test flow complete WhatsApp ↔ Dashboard! 🎉
