# TailorPro (ٹیلر پرو) - Digital Tailoring Register & Shop ERP

TailorPro is a production-ready, offline-first, bilingual (Urdu RTL default + English) application designed specifically for tailor shops, master cutters, and fashion boutiques. It completely replaces the traditional physical measurement register (*کھاتہ رجسٹر*) with a fast, modern, and tactile digital solution.

---

## ⚡ Quick Test on Laptop / Web (Ready to Use Right Now!)

You can immediately view and test TailorPro in your browser on your laptop without installing an APK:

### Option 1: Instant Local Web Server (Already Compiled & Live)
1. Double-click `start_web_server.bat` (or run `python -m http.server 8080 --directory build/web`).
2. Open your web browser to: **[http://localhost:8080](http://localhost:8080)**.
3. The complete application with Urdu font, themes, measurement register, orders, and reports is fully operational.

### Option 2: Live Hot-Reload Flutter Runner
```bash
flutter run -d chrome --web-renderer canvaskit
```

---

## 🌟 Key Features & Implementation Architecture

### 1. Bilingual Engine (Urdu RTL First + English Switchable)
- **Authentic Nastaliq Typography**: Bundled authentic `Noto Nastaliq Urdu` font (`assets/fonts/NotoNastaliqUrdu.ttf`).
- **Instant Toggle**: Switch between Urdu RTL and English LTR at any time from the app bar or settings.
- **Dual Numeral Support**: Toggle between Urdu numerals (۱ ۲ ۳ ۴ ۵ ۶ ۷ ۸ ۹ ۰) and Western numerals (1 2 3 4 5 6 7 8 9 0).

### 2. Multi-Business System & Staff Roles
- **Unlimited Independent Shops**: Host multiple branches or shops on one device with 100% database isolation.
- **Quick Switcher**: Change active business profile from the drawer/header.
- **Security & Privacy**: Optional 4-digit PIN lock per business.
- **Role-Based Access Control (RBAC)**:
  - *Owner (مالک)*: Full access to profit, expense, and staff wage reports.
  - *Manager (منیجر)*: Manage orders, customers, and delivery schedules.
  - *Cutter Master (ماسٹر / کٹر)*: View measurements, posture sketches, and update cutting stages.
  - *Tailor / Karigar (کاریگر / درزی)*: View assigned stitching jobs and piece-rate earnings.
  - *Cashier (کیشیئر)*: Record advances, invoice billing, and collect udhaar dues.

### 3. Core Measurement Register
- **Auto-Incrementing Serial Number**: Continuous serial register number matching traditional physical books (editable, configurable start).
- **Tactile Tailor Fractional Keypad**: Large-target custom on-screen keypad featuring fractional buttons (`¼`, `½`, `¾`, `⅛`, `⅜`, `⅝`, `⅞`) and `+½"` / `-½"` steppers.
- **7 Pre-Built Garment Templates**:
  - Shalwar Kameez (شلوار قمیض)
  - Kurta (کرتا)
  - Waistcoat (ویسٹ کوٹ)
  - Sherwani (شیروانی)
  - Pant & Shirt (پینٹ شرٹ)
  - Coat / Suit (کوٹ سوٹ)
  - Ladies Suit (لیڈیز سوٹ)
  - Custom Garments with user-defined fields
- **Dynamic Custom Option `(+)` Button**:
  - Tailors can tap the `(+)` button beside Collar, Cuff, Front Placket, Pocket, or Daman to add custom styles.
  - Added styles automatically persist in SQLite and appear as permanent selectable chips for future orders so tailors never have to type them twice.
- **Visual Posture Canvas**: Interactive drawing sketch pad to mark posture details (sloping shoulders, chest posture, stoop).
- **Voice Notes**: Record audio measurement instructions with voice playback.
- **Measurement History & Versioning**: Retains previous measurement revisions with single-tap "Copy Last Measurement" button.

### 4. Order Lifecycle & Status Pipeline
- **6-Stage Visual Kanban**:
  1. Received (وصول شدہ)
  2. Cutting (کٹنگ)
  3. Stitching (سلائی)
  4. Finishing (فنشنگ / کاج بٹن)
  5. Ready (تیار ہے)
  6. Delivered (حوالے شدہ)
- **Rush Orders**: Urgent flag with prominent badge and configurable surcharge.
- **Delivery Calendar**: Table calendar view highlighting delivery dates, trial dates, and overdue alerts.
- **Staff Piece-Rate Wages**: Assign Cutter and Stitcher per suit and automatically calculate wage liabilities.

### 5. Multi-Channel Billing, Invoices & Khata Ledger
- **Configurable Invoice Format**: Formats such as `INV-2026-0001`.
- **Payment Method Tracking**: Cash (نقد), JazzCash (جاز کیش), Easypaisa (ایزی پیسہ), Bank Transfer, and Credit / Udhaar (کھاتہ).
- **Thermal Printer & PDF Output**:
  - **80mm Thermal Receipt**: Standard 3-inch counter POS receipt with business details, line items, and QR code.
  - **58mm Mini Receipt**: Portable 2-inch Bluetooth printer layout.
  - **A4 / A5 Invoices**: Full printable document with optional measurement specs.
- **Tear-Off Customer Token Slip**: Customer copy with order summary and claim slip.
- **Customer Ledger & Dues List**: Filter customers with outstanding balances and send 1-tap WhatsApp payment reminders.

### 6. Reports & Expense Management
- **Dashboard Summary**: Today's orders, pending trials, cash collected, and outstanding dues.
- **Financial Analytics**: Daily, weekly, and monthly sales graphs, income vs expenses, and net profit.
- **Worker Productivity**: Suits cut and stitched per worker and unpaid wages ledger.
- **Exporting**: Instant export of customers, orders, and financial reports to Excel (`.xlsx`) and CSV.

### 7. 100% Offline, Privacy & Safety
- **Zero Cloud / Internet Dependency**: Runs 100% offline using local SQLite database.
- **Encrypted Local Backup (.tpbackup)**: 1-click encrypted ZIP backup exportable to SD Card, WhatsApp, or Google Drive.
- **Recycle Bin**: 30-day soft-delete protection with instant restore for customers and orders.

---

## 📱 Android APK & AAB Build Instructions

### One-Click Build Scripts:
- **`build_release_apk.bat`**: Runs linter, unit tests, and builds:
  - Universal APK: `build\app\outputs\flutter-apk\app-release.apk` (< 40MB)
  - ARM64: `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`
  - ARM32: `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk`
  - x86_64: `build\app\outputs\flutter-apk\app-x86_64-release.apk`
- **`build_aab.bat`**: Builds `app-release.aab` for Google Play Console.
- **`run_tests.bat`**: Runs static analysis (`flutter analyze`) and automated tests (`flutter test`).

---

## 🧪 Automated Testing & Verification
The test suite validates:
- `BillingEngine`: Grand total calculations, urgent surcharge, discounts, advance payments, and ledger balances.
- `FractionFormatter`: Tailor fractional notations (`¼`, `½`, `¾`, `⅛`, `⅜`, `⅝`, `⅞`) and unicode conversions.
- `ModelsSerialization`: SQLite map serialization, JSON style options decoding, and data integrity.

Run tests anytime with:
```bash
flutter test
```

---

## 🔮 Future Roadmap
- Local Wi-Fi multi-device sync between shop counter and workshop cutting table.
- Direct SMS Gateway integration.
- Customer-facing online order tracking portal.
