# Setup Integrasi Backend Python dengan Frontend Next.js

## Overview
Dokumentasi ini menjelaskan cara menghubungkan sistem login antara backend Python (FastAPI) dengan frontend Next.js.

## Struktur Project
```
/Users/mm/Desktop/Dashboard/
├── backend-dashboard-python/     # Backend FastAPI
└── dashboard-message-center/     # Frontend Next.js
```

---

## 🔧 Setup Backend (Python FastAPI)

### 1. Masuk ke direktori backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
```

### 2. Aktifkan virtual environment
```bash
source .venv/bin/activate
```

### 3. Install dependencies (jika belum)
```bash
pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv bcrypt pyjwt python-multipart
```

### 4. Setup environment variables
Buat file `.env` di root backend:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/database_name
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

### 5. Buat demo users (Admin & Agent)
```bash
python3 seed_users.py
```

Ini akan membuat 2 akun demo:
- **Admin** — admin | admin123
- **Agent** — agent | agent123

### 6. Jalankan backend server
```bash
uvicorn app.main:app --reload --port 8000
```

Backend akan berjalan di: **http://localhost:8000**

### 7. API Endpoints yang tersedia
- `POST /auth/login` - Login endpoint
  - Body: `{ "identifier": "email/username", "password": "password" }`
  - Response: `{ "message", "data": {...}, "access_token", "token_type" }`

- `POST /auth/register` - Register endpoint
  - Body: `{ "name", "email", "username", "password", "role" }`

---

## 🎨 Setup Frontend (Next.js)

### 1. Masuk ke direktori frontend
```bash
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
```

### 2. Install dependencies
```bash
npm install
```

### 3. Environment Variables
File `.env.local` sudah dibuat dengan konfigurasi:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

Jika backend berjalan di port lain, sesuaikan URL-nya.

### 4. Jalankan development server
```bash
npm run dev
```

Frontend akan berjalan di: **http://localhost:3000**

---

## ✅ Testing Login

### 1. Demo users sudah tersedia!
Jika Anda sudah menjalankan `python3 seed_users.py`, kedua akun ini sudah siap digunakan:
- **Admin** — username: `admin` | password: `admin123`
- **Agent** — username: `agent` | password: `agent123`

### 2. Test login via frontend
1. Buka browser: http://localhost:3000/login
2. Masukkan username atau email: `admin`
3. Masukkan password: `admin123`
4. Klik "Continue"

### 3. Verifikasi login berhasil
Jika berhasil, user akan diredirect ke:
- **Admin** → `/dashboard-admin`
- **Agent/Karyawan** → `/dashboard-agent`

---

## 🔑 Fitur yang Sudah Terintegrasi

### Frontend
- ✅ API Service untuk autentikasi ([lib/api/auth.ts](dashboard-message-center/lib/api/auth.ts))
- ✅ Zustand store dengan persist ([store/authStore.tsx](dashboard-message-center/store/authStore.tsx))
- ✅ Login page dengan async handling ([app/login/page.tsx](dashboard-message-center/app/login/page.tsx))
- ✅ Token disimpan di localStorage
- ✅ Auto redirect berdasarkan role
- ✅ Logout functionality dengan clear token & localStorage
- ✅ Protected routes untuk admin & agent
- ✅ Improved error handling

### Backend
- ✅ CORS middleware untuk allow frontend
- ✅ Login dengan username/email
- ✅ JWT token generation
- ✅ Password hashing dengan bcrypt
- ✅ Role-based authentication (admin/karyawan)

---

## 📝 Notes

### Role Mapping
Backend menggunakan role: `admin`, `karyawan`
Frontend mapping:
- `admin` → `admin`
- `karyawan` → `agent`

### Token Storage
Token disimpan di localStorage dengan key: `auth-storage`

### CORS Configuration
Backend mengizinkan request dari:
- http://localhost:3000
- http://127.0.0.1:3000

---

## 🐛 Troubleshooting

### CORS Error
Jika mendapat CORS error, pastikan:
1. Backend sudah running di port 8000
2. CORS middleware sudah ditambahkan di [backend-dashboard-python/app/main.py](backend-dashboard-python/app/main.py:21-28)

### Login Failed
1. Cek backend logs untuk error details
2. Pastikan database connection berhasil
3. Verifikasi user ada di database
4. Cek password match

### Network Error
1. Pastikan backend running: `curl http://localhost:8000`
2. Cek `.env.local` di frontend sudah benar
3. Pastikan tidak ada firewall blocking port 8000

---

## 🚀 Quick Start Commands

### Terminal 1 - Backend
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
source .venv/bin/activate

# Buat demo users (hanya perlu sekali)
python3 seed_users.py

# Jalankan server
uvicorn app.main:app --reload --port 8000
```

### Terminal 2 - Frontend
```bash
cd /Users/mm/Desktop/Dashboard/dashboard-message-center
npm run dev
```

### Terminal 3 - Test
```bash
# Test backend health
curl http://localhost:8000

# Test database connection
curl http://localhost:8000/db-connect

# Open frontend
open http://localhost:3000/login
```

---

## 📚 File Changes Summary

### Files Created
1. `dashboard-message-center/.env.local` - Environment variables
2. `dashboard-message-center/.env.example` - Environment template
3. `dashboard-message-center/lib/api/auth.ts` - API service layer
4. `backend-dashboard-python/seed_users.py` - Script untuk membuat demo users

### Files Modified
1. `dashboard-message-center/store/authStore.tsx` - Added API integration & logout with localStorage clear
2. `dashboard-message-center/app/login/page.tsx` - Made login async with error handling
3. `dashboard-message-center/components/ui/app-sidebar.tsx` - Added logout redirect to login
4. `dashboard-message-center/components/chat/chat-list.tsx` - Added logout button for agent dashboard
5. `backend-dashboard-python/app/main.py` - Added CORS middleware

---

## ✨ Next Steps

1. Tambahkan error handling yang lebih detail
2. Implementasi token refresh mechanism
3. Tambahkan protected route middleware
4. Setup automatic token expiry check
5. Tambahkan loading states yang lebih baik
6. Implementasi logout functionality yang clear token

---

**Happy Coding! 🎉**
