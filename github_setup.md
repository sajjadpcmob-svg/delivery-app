# 🚛 مدیریت ارسال کالا — راهنمای نصب

## ۱. ساخت پروژه Supabase

### ۱.۱ ساخت پروژه جدید
1. به [supabase.com](https://supabase.com) بروید و وارد شوید
2. روی **New Project** کلیک کنید
3. نام پروژه و رمز عبور دیتابیس را وارد کنید
4. منطقه (Region) نزدیک‌ترین به خودتان انتخاب کنید
5. روی **Create new project** کلیک کنید

### ۱.۲ اجرای SQL Schema
1. در داشبورد پروژه، از منوی سمت چپ **SQL Editor** را انتخاب کنید
2. محتوای فایل `supabase_schema.sql` را کپی و پیست کنید
3. روی **Run** کلیک کنید
4. تأیید کنید که جداول ایجاد شده‌اند (از منوی **Table Editor** بررسی کنید)

### ۱.۳ دریافت کلیدهای اتصال
1. از منوی سمت چپ **Settings** → **API** را انتخاب کنید
2. دو مقدار زیر را یادداشت کنید:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbG...`

### ۱.۴ فعال‌سازی Realtime
1. از منوی سمت چپ **Database** → **Replication** را انتخاب کنید
2. روی **Source** کلیک کنید
3. تمام جداول زیر را تیک بزنید:
   - `products`
   - `vehicles`
   - `deliveries`
   - `dispatches`
   - `dispatch_products`
   - `notifications`
4. ذخیره کنید

> **نکته:** جداول `passwords` و `dispatch_products` نیازی به Realtime ندارند ولی مشکلی هم ایجاد نمی‌کنند.

---

## ۲. تنظیم کلیدها در فایل Index.html

در فایل `Index.html` دو خط زیر را پیدا کنید (حدود خط ۱۶۹۰):

```javascript
var SUPABASE_URL = 'https://jbvrgaujnmkuzvlremqm.supabase.co';
var SUPABASE_ANON_KEY = 'sb_publishable_fRR3ihBKPwg5oD4aWArv7A_31k84qeS';
```

و مقادیر خودتان را جایگزین کنید:

```javascript
var SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
var SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

---

## ۳. ساخت ریپوی GitHub Pages

### ۳.۱ ساخت ریپو
1. به [github.com](https://github.com) بروید و وارد شوید
2. روی **New** کلیک کنید تا ریپوی جدید بسازید
3. نام ریپو: `delivery-app` (یا هر نام دلخواه)
4. روی **Create repository** کلیک کنید

### ۳.۲ آپلود فایل‌ها
فایل‌های زیر را در ریشه ریپو آپلود کنید:

```
delivery-app/
├── Index.html          ← فایل اصلی برنامه
├── manifest.json       ← مانیفست PWA
├── sw.js              ← Service Worker
└── icons/
    ├── icon-72.png
    ├── icon-96.png
    ├── icon-128.png
    ├── icon-144.png
    ├── icon-152.png
    ├── icon-192.png
    ├── icon-384.png
    └── icon-512.png
```

### ۳.۳ فعال‌سازی GitHub Pages
1. در صفحه ریپو، به **Settings** بروید
2. از منوی سمت چپ **Pages** را انتخاب کنید
3. در بخش **Source**، گزینه **Deploy from a branch** را انتخاب کنید
4. Branch: `main` و پوشه: `/ (root)` را انتخاب کنید
5. روی **Save** کلیک کنید
6. بعد از چند دقیقه، آدرس سایت شما فعال می‌شود:
   `https://YOUR_USERNAME.github.io/delivery-app/`

---

## ۴. نصب روی گوشی (PWA)

1. آدرس سایت را در مرورگر گوشی باز کنید
2. در Chrome Android: منوی ⋮ → **Add to Home screen**
3. در Safari iOS: دکمه اشتراک‌گذاری → **Add to Home Screen**
4. آیکون برنامه روی صفحه اصلی گوشی ظاهر می‌شود

---

## ۵. اطلاعات فنی

| آیتم | مقدار |
|-------|-------|
| نسخه | 6.22 |
| زبان | فارسی (RTL) |
| جاوااسکریپت | ES5 |
| دیتابیس | Supabase (PostgreSQL) |
| همگام‌سازی | Realtime + HTTP API |
| PWA | بله (آفلاین هم کار می‌کند) |
| رمز عبور پیش‌فرض | `1234` |

### حساب‌های کاربری
| حساب | نقش | رمز عبور |
|------|------|----------|
| تحویل | ثبت و ارسال محصول | 1234 |
| تحول | دریافت و بارگیری | 1234 |

---

## ۶. عیب‌یابی

### دکمه‌های تحویل/تحول کار نمی‌کنند
- مطمئن شوید فایل `Index.html` نسخه ۶.۲۲ یا بالاتر باشد
- کنسول مرورگر (F12) را باز کنید و خطاهای جاوااسکریپت را بررسی کنید

### «آفلاین» نمایش داده می‌شود
- اتصال اینترنت را بررسی کنید
- مطمئن شوید `SUPABASE_URL` و `SUPABASE_ANON_KEY` درست وارد شده‌اند
- مطمئن شوید جداول در Supabase ایجاد شده‌اند

### داده‌ها همگام نمی‌شوند
- Realtime را در Supabase فعال کنید (بخش ۱.۴)
- Policyهای RLS را بررسی کنید (باید `Allow all` باشند)

### رمز عبور کار نمی‌کند
- رمز پیش‌فرض: `1234`
- بعد از ورود می‌توانید رمز را تغییر دهید