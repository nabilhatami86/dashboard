# Troubleshooting Guide - Login Integration

## Error: "Network error. Pastikan backend server berjalan di http://localhost:8000"

### Penyebab:
Backend Python tidak berjalan atau tidak dapat diakses.

### Solusi:
1. Buka terminal baru
2. Jalankan backend:
   ```bash
   cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
   source .venv/bin/activate
   uvicorn app.main:app --reload --port 8000
   ```
3. Cek apakah backend berjalan:
   ```bash
   curl http://localhost:8000
   ```
   Harusnya return: `{"status":"ok"}`

---

## Error: "Invalid credentials" atau "Email atau password salah"

### Penyebab:
Username/email atau password tidak sesuai dengan yang ada di database.

### Solusi:
1. Pastikan Anda sudah membuat demo users:
   ```bash
   cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
   source .venv/bin/activate
   python3 seed_users.py
   ```

2. Gunakan credentials yang benar:
   - **Admin**: username `admin` password `admin123`
   - **Agent**: username `agent` password `agent123`

3. Jika masih error, cek database:
   ```bash
   # Masuk ke PostgreSQL
   psql -U your_username -d your_database

   # List semua users
   SELECT id, username, email, role FROM users;
   ```

---

## Error: CORS Error di Browser Console

### Penyebab:
Backend tidak mengizinkan request dari frontend origin.

### Solusi:
1. Pastikan CORS middleware sudah ditambahkan di [backend-dashboard-python/app/main.py](backend-dashboard-python/app/main.py:21-28)

2. Verifikasi konfigurasi CORS:
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

3. Restart backend server setelah perubahan

---

## Error: "Server error: 500" atau "Server error: 422"

### Penyebab:
- 500: Internal server error di backend
- 422: Validation error (data yang dikirim tidak sesuai format)

### Solusi untuk 500:
1. Cek logs di terminal backend untuk detail error
2. Pastikan database connection berfungsi:
   ```bash
   curl http://localhost:8000/db-connect
   ```
3. Cek apakah semua environment variables sudah benar di `.env`

### Solusi untuk 422:
1. Pastikan format login request benar:
   ```json
   {
     "identifier": "admin",
     "password": "admin123"
   }
   ```
2. Cek apakah schema di backend sesuai

---

## Frontend Tidak Redirect Setelah Login

### Penyebab:
Role mapping tidak sesuai atau user state tidak ter-update.

### Solusi:
1. Buka browser DevTools → Application → Local Storage
2. Cari key `auth-storage`
3. Hapus local storage dan coba login lagi
4. Pastikan role mapping benar di [store/authStore.tsx](dashboard-message-center/store/authStore.tsx:32-38):
   - Backend `admin` → Frontend `admin`
   - Backend `agent` → Frontend `agent`
   - Backend `karyawan` → Frontend `agent`

---

## Database Connection Failed

### Error Message:
```
❌ PostgreSQL CONNECTION FAILED
```

### Solusi:
1. Pastikan PostgreSQL berjalan:
   ```bash
   # macOS
   brew services list
   # atau
   pg_ctl status
   ```

2. Start PostgreSQL jika belum:
   ```bash
   # macOS
   brew services start postgresql@14
   # atau
   pg_ctl start
   ```

3. Cek file `.env` di backend:
   ```env
   DATABASE_URL=postgresql://username:password@localhost:5432/database_name
   ```

4. Test connection manual:
   ```bash
   psql -U username -d database_name
   ```

---

## Port Already in Use

### Error: "Address already in use: 8000" atau "Port 3000 already in use"

### Solusi Backend (Port 8000):
```bash
# Cari process yang menggunakan port 8000
lsof -ti:8000

# Kill process
kill -9 $(lsof -ti:8000)

# Atau gunakan port lain
uvicorn app.main:app --reload --port 8001
```

### Solusi Frontend (Port 3000):
```bash
# Kill process di port 3000
lsof -ti:3000 | xargs kill -9

# Atau npm akan otomatis menawarkan port lain
npm run dev
```

---

## Token Tidak Tersimpan / Hilang

### Penyebab:
Browser tidak mengizinkan localStorage atau ada masalah dengan persist middleware.

### Solusi:
1. Cek browser console untuk error
2. Pastikan browser tidak dalam mode incognito/private
3. Clear browser cache dan local storage
4. Verifikasi persist config di [authStore.tsx](dashboard-message-center/store/authStore.tsx:60-63):
   ```typescript
   {
     name: "auth-storage",
     partialize: (state) => ({ user: state.user }),
   }
   ```

---

## "Module not found" Error di Frontend

### Error:
```
Module not found: Can't resolve '@/lib/api/auth'
```

### Solusi:
1. Pastikan file [lib/api/auth.ts](dashboard-message-center/lib/api/auth.ts) ada
2. Restart development server:
   ```bash
   # Ctrl+C untuk stop
   npm run dev
   ```
3. Clear Next.js cache:
   ```bash
   rm -rf .next
   npm run dev
   ```

---

## BCrypt Warning

### Warning:
```
(trapped) error reading bcrypt version
```

### Info:
Ini hanya warning dan tidak mempengaruhi fungsi login. Password tetap ter-hash dengan baik.

### Solusi (Optional):
Jika ingin menghilangkan warning:
```bash
cd /Users/mm/Desktop/Dashboard/backend-dashboard-python
source .venv/bin/activate
pip uninstall bcrypt
pip install bcrypt
```

---

## Login Berhasil Tapi Tidak Ada Data User

### Solusi:
1. Cek response dari API di Network tab browser DevTools
2. Pastikan backend mengirim data lengkap:
   ```json
   {
     "message": "Login success",
     "data": {
       "id": 1,
       "name": "Admin User",
       "username": "admin",
       "email": "admin@example.com",
       "role": "admin"
     },
     "access_token": "eyJ...",
     "token_type": "bearer"
   }
   ```
3. Verifikasi mapping di authStore

---

## Need More Help?

### Debugging Steps:
1. **Backend Health Check**:
   ```bash
   curl http://localhost:8000
   curl http://localhost:8000/db-connect
   ```

2. **Test Login via curl**:
   ```bash
   curl -X POST http://localhost:8000/auth/login \
     -H "Content-Type: application/json" \
     -d '{"identifier": "admin", "password": "admin123"}'
   ```

3. **Frontend Console**:
   - Buka DevTools (F12)
   - Tab Console untuk error messages
   - Tab Network untuk API requests

4. **Backend Logs**:
   - Lihat terminal yang menjalankan uvicorn
   - Error details akan muncul di sini

### Contact Info:
Jika masih ada masalah, simpan:
1. Screenshot error message
2. Backend logs
3. Browser console logs
4. Steps to reproduce

---

**Happy Debugging! 🐛🔧**
