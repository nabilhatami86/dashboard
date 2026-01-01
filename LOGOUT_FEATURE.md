# 🚪 Logout Feature Documentation

## Overview
Logout functionality telah diimplementasikan untuk membersihkan token authentication dan mengarahkan user kembali ke halaman login.

---

## 🎯 Fitur Logout

### Apa yang Terjadi Saat Logout?
1. **Clear User State** - User object di Zustand store di-set menjadi `null`
2. **Clear localStorage** - Token authentication dihapus dari browser storage
3. **Redirect** - User otomatis diarahkan ke halaman login (`/login`)
4. **Protected Routes** - Layout akan otomatis redirect ke login jika tidak ada user

---

## 📍 Lokasi Logout Button

### 1. Admin Dashboard
**Location**: Sidebar kiri
**Component**: [components/ui/app-sidebar.tsx](dashboard-message-center/components/ui/app-sidebar.tsx:144-152)

```tsx
{/* Logout Button di bagian bawah sidebar */}
<div className="border-t border-white/10 p-4">
  <button
    onClick={handleLogout}
    className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-white/70 hover:bg-white/5 transition-colors"
  >
    <LogOut className="h-5 w-5" />
    {open && <span className="text-sm">Logout</span>}
  </button>
</div>
```

### 2. Agent Dashboard
**Location**: Chat List (sidebar kiri)
**Component**: [components/chat/chat-list.tsx](dashboard-message-center/components/chat/chat-list.tsx:131-140)

```tsx
{/* Logout Button */}
<div className="p-3 border-t border-neutral-200">
  <Button
    onClick={handleLogout}
    variant="ghost"
    className="w-full justify-start gap-2 hover:bg-neutral-100 text-neutral-700"
  >
    <LogOut className="h-4 w-4" />
    <span className="text-sm">Logout</span>
  </Button>
</div>
```

---

## 🔧 Implementasi Detail

### Auth Store Logout Function
**File**: [store/authStore.tsx](dashboard-message-center/store/authStore.tsx:52-58)

```typescript
logout: () => {
  // Clear user state
  set({ user: null });

  // Clear localStorage
  localStorage.removeItem("auth-storage");
}
```

### Logout Handler Pattern
Setiap component yang memiliki logout button menggunakan pattern yang sama:

```typescript
const router = useRouter();
const logout = useAuthStore((state) => state.logout);

const handleLogout = () => {
  logout();
  router.replace("/login");
};
```

**Penjelasan**:
- `logout()` - Memanggil store function untuk clear state & localStorage
- `router.replace("/login")` - Redirect ke login page (replace = tidak bisa back)

---

## 🛡️ Protected Routes

### Admin Layout Protection
**File**: [app/dashboard-admin/layout.tsx](dashboard-message-center/app/dashboard-admin/layout.tsx:17-27)

```typescript
useEffect(() => {
  if (!user) {
    router.replace("/login");
    return;
  }
  if (user.role !== "admin") {
    router.replace("/dashboard-agent");
  }
}, [user, router]);
```

### Agent Layout Protection
**File**: [app/dashboard-agent/layout.tsx](dashboard-message-center/app/dashboard-agent/layout.tsx:16-25)

```typescript
useEffect(() => {
  if (!user) {
    router.replace("/login");
    return;
  }
  if (user.role !== "agent") {
    router.replace("/dashboard-admin");
  }
}, [user, router]);
```

**Penjelasan**:
- Setelah logout, `user` menjadi `null`
- Layout akan otomatis detect dan redirect ke `/login`
- Tidak perlu manual redirect di logout handler

---

## 🔍 Flow Diagram

```
User clicks "Logout"
        ↓
handleLogout() dipanggil
        ↓
logout() dari authStore
        ↓
    ┌────────────────────┐
    │ set({ user: null })│
    └────────────────────┘
        ↓
    ┌─────────────────────────────────────┐
    │ localStorage.removeItem("auth-...")│
    └─────────────────────────────────────┘
        ↓
router.replace("/login")
        ↓
Login Page ditampilkan
```

---

## ✅ Testing Logout

### Manual Testing Steps:

1. **Login sebagai Admin**
   ```
   - Buka http://localhost:3000/login
   - Login dengan: admin / admin123
   - Verifikasi redirect ke /dashboard-admin
   ```

2. **Test Logout Admin**
   ```
   - Klik tombol "Logout" di sidebar
   - Verifikasi redirect ke /login
   - Buka DevTools → Application → Local Storage
   - Pastikan "auth-storage" sudah terhapus
   ```

3. **Login sebagai Agent**
   ```
   - Login dengan: agent / agent123
   - Verifikasi redirect ke /dashboard-agent
   ```

4. **Test Logout Agent**
   ```
   - Klik tombol "Logout" di chat list
   - Verifikasi redirect ke /login
   - Verifikasi localStorage cleared
   ```

5. **Test Protected Routes**
   ```
   - Setelah logout, coba akses:
     - http://localhost:3000/dashboard-admin
     - http://localhost:3000/dashboard-agent
   - Keduanya harus auto-redirect ke /login
   ```

### Browser Console Testing:
```javascript
// Cek user state
const state = localStorage.getItem('auth-storage');
console.log(JSON.parse(state));

// Setelah logout, harusnya return null atau error
```

---

## 🐛 Troubleshooting

### User Tidak Redirect Setelah Logout

**Penyebab**: Layout protection tidak berjalan

**Solusi**:
1. Hard refresh browser (Cmd/Ctrl + Shift + R)
2. Clear browser cache
3. Cek console untuk error

### localStorage Masih Ada Setelah Logout

**Penyebab**: Logout function tidak terpanggil dengan benar

**Solusi**:
1. Cek browser console untuk error
2. Verifikasi `handleLogout` dipanggil:
   ```typescript
   const handleLogout = () => {
     console.log("Logout clicked"); // Debug log
     logout();
     router.replace("/login");
   };
   ```

### Bisa Back ke Dashboard Setelah Logout

**Penyebab**: Menggunakan `router.push` bukan `router.replace`

**Solusi**:
- Gunakan `router.replace("/login")` bukan `router.push("/login")`
- `replace` menghapus history, sehingga tidak bisa back

### Token Masih Aktif di Backend

**Info**:
- Frontend logout hanya clear localStorage
- Backend JWT token masih valid sampai expire
- Ini normal behavior untuk JWT

**Solusi** (Optional):
- Implement token blacklist di backend
- Atau gunakan refresh token pattern

---

## 🔐 Security Notes

### Current Implementation
✅ **Aman untuk Frontend-only logout**:
- Token dihapus dari browser
- User tidak bisa akses protected routes
- Re-login required untuk akses ulang

⚠️ **JWT Token Masih Valid**:
- Token yang sudah di-generate masih valid sampai expire
- Jika ada yang punya copy token, masih bisa digunakan sampai expire
- Token expiry default: 60 menit (configurable di backend)

### Recommended Improvements (Optional)
1. **Token Blacklist**: Simpan revoked tokens di backend
2. **Refresh Tokens**: Implement refresh token pattern
3. **Session Management**: Track active sessions di backend
4. **Shorter Expiry**: Kurangi token expiry time untuk security

---

## 📚 Related Files

### Frontend
- [store/authStore.tsx](dashboard-message-center/store/authStore.tsx) - Auth state management
- [components/ui/app-sidebar.tsx](dashboard-message-center/components/ui/app-sidebar.tsx) - Admin logout button
- [components/chat/chat-list.tsx](dashboard-message-center/components/chat/chat-list.tsx) - Agent logout button
- [app/dashboard-admin/layout.tsx](dashboard-message-center/app/dashboard-admin/layout.tsx) - Admin route protection
- [app/dashboard-agent/layout.tsx](dashboard-message-center/app/dashboard-agent/layout.tsx) - Agent route protection

### Backend
- [app/utils/jwt.py](../backend-dashboard-python/app/utils/jwt.py) - JWT token generation
- [app/config_env.py](../backend-dashboard-python/app/config_env.py) - Token expiry configuration

---

## ✨ Future Enhancements

1. **Logout Confirmation Modal**
   - Tambah dialog "Apakah yakin logout?"
   - Prevent accidental logout

2. **Auto Logout on Token Expire**
   - Detect expired token
   - Auto logout & show message

3. **Activity Timeout**
   - Auto logout after X minutes inactive
   - Warning before timeout

4. **Multi-Device Logout**
   - Logout dari semua device
   - Requires backend token blacklist

5. **Session History**
   - Track login/logout history
   - Show last login time

---

**Happy Coding! 🎉**
