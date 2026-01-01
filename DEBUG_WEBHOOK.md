# 🔍 Debug: WhatsApp Message Tidak Masuk

## ❌ Problem: Kirim WhatsApp tapi tidak masuk ke database/dashboard

Mari kita debug step-by-step:

---

## Step 1: Cek Webhook Configuration di WHAPI

### A. Apakah webhook sudah di-set?

**Login ke WHAPI Dashboard:**
- URL: https://whapi.cloud
- Login dengan akun Anda

**Check Settings:**
1. Pilih channel WhatsApp Anda
2. Buka menu **Webhooks** atau **Settings**
3. **Apakah Webhook URL sudah di-set?**

   Harus: `https://d79ed692219b.ngrok-free.app/webhook/whapi`

### B. Test Webhook dari WHAPI Dashboard

Beberapa provider punya tombol **"Test Webhook"**:
1. Click "Test Webhook"
2. Lihat apakah ada response success
3. Check error message jika ada

---

## Step 2: Monitor ngrok Web Interface

**PENTING:** Ini cara paling efektif untuk debug!

### Buka ngrok Web Interface:
```
http://127.0.0.1:4040
```

### Apa yang harus Anda lihat:

#### Jika Webhook BEKERJA:
```
POST /webhook/whapi    200 OK    2ms
```

Click request untuk lihat detail:
- Request body: WhatsApp message payload
- Response: {"status":"ok","chat_id":X}

#### Jika Webhook TIDAK BEKERJA:
- **TIDAK ADA REQUEST SAMA SEKALI** → Webhook belum di-set di WHAPI
- **404 Not Found** → URL salah
- **500 Error** → Backend error

---

## Step 3: Cek Backend Logs

Di terminal backend, seharusnya ada log:

### Jika BEKERJA:
```
INFO: Received webhook data: {'messages': [...]}
INFO: Created new chat for 628XXX@c.us
INFO: Saved customer message to chat 7
INFO: Saved bot reply to chat 7
```

### Jika TIDAK BEKERJA:
- **TIDAK ADA LOG SAMA SEKALI** → Webhook tidak sampai ke backend

---

## Step 4: Test Webhook Manual

Mari test apakah webhook endpoint berfungsi:

```bash
# Test 1: Local (harus success)
curl -X POST http://localhost:8000/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "from": "628123456789@c.us",
      "from_name": "Manual Test",
      "text": {"body": "Test manual dari curl"}
    }]
  }'

# Expected: {"status":"ok","mode":"bot","chat_id":X,"bot_replied":true}
```

```bash
# Test 2: Via ngrok (bypass browser warning dulu!)
# Buka browser: https://d79ed692219b.ngrok-free.app
# Click "Visit Site"

# Kemudian:
curl -X POST https://d79ed692219b.ngrok-free.app/webhook/whapi \
  -H "Content-Type: application/json" \
  -H "User-Agent: WhatsApp/1.0" \
  -d '{
    "messages": [{
      "from": "628123456789@c.us",
      "from_name": "Manual Test ngrok",
      "text": {"body": "Test via ngrok"}
    }]
  }'
```

---

## Step 5: Kemungkinan Masalah & Solusi

### Problem A: Webhook URL Salah

**Gejala:**
- ngrok Web UI tidak ada request
- Backend tidak ada log

**Check:**
1. ngrok URL benar? Harus: `https://d79ed692219b.ngrok-free.app`
2. Path benar? Harus ada `/webhook/whapi` di akhir

**Solusi:**
- Update webhook di WHAPI dashboard
- Full URL: `https://d79ed692219b.ngrok-free.app/webhook/whapi`

---

### Problem B: ngrok Browser Warning Belum Di-bypass

**Gejala:**
- Webhook di WHAPI sudah di-set
- Tapi tidak ada request di ngrok Web UI

**Solusi:**
1. Buka browser
2. Visit: `https://d79ed692219b.ngrok-free.app`
3. **MUST CLICK "Visit Site"** pada warning page
4. Setelah itu, webhook akan bekerja

---

### Problem C: ngrok Stopped/Restart

**Gejala:**
- Webhook sempat bekerja
- Tapi sekarang tidak

**Check:**
```bash
ps aux | grep ngrok
```

**Solusi:**
1. Restart ngrok: `ngrok http 8000`
2. **URL BERUBAH!** Copy URL baru
3. **Update webhook di WHAPI** dengan URL baru

---

### Problem D: Backend Not Running

**Gejala:**
- ngrok Web UI ada request
- Tapi ada error 502/503

**Check:**
```bash
curl http://localhost:8000/
```

**Solusi:**
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
python3 -m uvicorn app.main:app --reload
```

---

### Problem E: Webhook Event Not Configured

**Gejala:**
- Webhook di-set tapi tidak ada request

**Check di WHAPI Dashboard:**
- Apakah event **"Incoming Messages"** enabled?
- Apakah webhook untuk **"messages"** event aktif?

**Solusi:**
- Enable "Incoming Messages" event
- Enable webhook untuk message events

---

## ✅ Verification Checklist

Cek satu-per-satu:

### 1. Backend Running?
```bash
curl http://localhost:8000/
# Expected: {"status":"ok"}
```
- [ ] ✅ Backend running

### 2. ngrok Running?
```bash
ps aux | grep ngrok
# Should show: ngrok http 8000
```
- [ ] ✅ ngrok running

### 3. ngrok URL Correct?
Di terminal ngrok, copy URL:
```
Forwarding    https://xxx.ngrok-free.app -> http://localhost:8000
```
- [ ] ✅ URL copied: `https://d79ed692219b.ngrok-free.app`

### 4. Browser Warning Bypassed?
```bash
# Buka di browser
https://d79ed692219b.ngrok-free.app
# Click "Visit Site"
```
- [ ] ✅ Warning bypassed

### 5. Webhook Set di WHAPI?
Login https://whapi.cloud → Check webhook URL
```
https://d79ed692219b.ngrok-free.app/webhook/whapi
```
- [ ] ✅ Webhook configured

### 6. Test Manual Webhook
```bash
curl -X POST http://localhost:8000/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"from":"test@c.us","text":{"body":"test"}}]}'
```
- [ ] ✅ Response: {"status":"ok"}

### 7. Monitor ngrok Web UI
```
http://127.0.0.1:4040
```
- [ ] ✅ Interface accessible

### 8. Send WhatsApp Test
Kirim message ke bot number
- [ ] ✅ Request muncul di ngrok Web UI
- [ ] ✅ Backend log: "Received webhook data"
- [ ] ✅ Chat muncul di database

---

## 🎯 Quick Debug Script

Run this untuk comprehensive check:

```bash
#!/bin/bash
echo "=== Debug Webhook Setup ==="
echo ""

echo "1. Checking Backend..."
if curl -s http://localhost:8000/ | grep -q "ok"; then
    echo "   ✅ Backend is running"
else
    echo "   ❌ Backend NOT running!"
    echo "   Fix: cd backend-dashboard-python && python3 -m uvicorn app.main:app --reload"
fi
echo ""

echo "2. Checking ngrok..."
if ps aux | grep -q "[n]grok"; then
    echo "   ✅ ngrok is running"
else
    echo "   ❌ ngrok NOT running!"
    echo "   Fix: ngrok http 8000"
fi
echo ""

echo "3. Testing webhook endpoint locally..."
response=$(curl -s -X POST http://localhost:8000/webhook/whapi \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"from":"test@c.us","text":{"body":"test"}}]}')

if echo "$response" | grep -q "ok"; then
    echo "   ✅ Webhook endpoint working"
    echo "   Response: $response"
else
    echo "   ❌ Webhook endpoint error!"
    echo "   Response: $response"
fi
echo ""

echo "4. Checking database..."
chat_count=$(curl -s http://localhost:8000/chats/ | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
echo "   Total chats in DB: $chat_count"
echo ""

echo "5. Next steps:"
echo "   - Open ngrok Web UI: http://127.0.0.1:4040"
echo "   - Set webhook in WHAPI: https://d79ed692219b.ngrok-free.app/webhook/whapi"
echo "   - Send WhatsApp message to test"
echo "   - Monitor requests in ngrok Web UI"
```

Save as `debug_webhook.sh` dan run:
```bash
chmod +x debug_webhook.sh
./debug_webhook.sh
```

---

## 🔧 Most Common Issue

**90% of the time, the problem is:**

1. ❌ **Webhook URL di WHAPI belum di-set/salah**
2. ❌ **ngrok browser warning belum di-bypass**
3. ❌ **ngrok URL berubah setelah restart**

**Fix:**
1. ✅ Login WHAPI → Set webhook: `https://d79ed692219b.ngrok-free.app/webhook/whapi`
2. ✅ Buka `https://d79ed692219b.ngrok-free.app` di browser → Click "Visit Site"
3. ✅ Jika restart ngrok, update webhook URL di WHAPI

---

## 📞 Support

Jika masih bermasalah, check:

1. **ngrok Web UI:** `http://127.0.0.1:4040`
   - Apakah ada request masuk?
   - Apa status code-nya?

2. **Backend Logs:**
   - Apakah ada log "Received webhook data"?
   - Apakah ada error?

3. **WHAPI Dashboard:**
   - Apakah webhook status "Active"?
   - Apakah ada webhook delivery logs/history?

---

**Most likely fix: Double-check webhook URL di WHAPI.cloud!** 🎯
