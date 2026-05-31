# 🎓 EduStream — School Management System

A full-featured **School Management System** built with **Flutter**, supporting Web, Android, and iOS platforms. EduStream streamlines student management, fee collection, invoice generation, and academic scheduling — all in one clean, modern interface.

---

## ✨ Features

- 🏠 **Dashboard** — Real-time stats: total students, fees collected, pending invoices, and fee collection trend charts
- 👨‍🎓 **Student Directory** — Enroll, search, filter, and manage students with class/section support
- 🧾 **Fees & Invoices** — Automated invoice generation, billing month tracking, PAID/PENDING status
- 📄 **PDF Invoice Generation** — Professional invoices with QR code and FBR integration
- 📅 **Academic Calendar** — Upcoming events and exam scheduling
- 🔐 **Authentication** — JWT-based secure login with token persistence
- 🌐 **Cross-Platform** — Runs on Web, Android, and iOS

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| **Flutter** | UI Framework |
| **Dart** | Programming Language |
| **fl_chart** | Charts & Analytics |
| **pdf + printing** | PDF Generation |
| **http** | REST API Integration |
| **shared_preferences** | Local Token Storage |
| **google_fonts** | Typography |
| **intl** | Date & Currency Formatting |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── api/
│   │   ├── api_service.dart       # Base HTTP client
│   │   ├── auth_api.dart          # Login / Auth endpoints
│   │   ├── dashboard_api.dart     # Dashboard stats
│   │   ├── invoice_api.dart       # Invoice CRUD
│   │   └── student_api.dart       # Student CRUD
│   ├── theme/
│   │   ├── colors.dart            # App color palette
│   │   └── text_styles.dart       # Typography styles
│   └── utils/
│       └── pdf_generator.dart     # PDF invoice builder
├── models/
│   ├── student_model.dart         # Student data model
│   └── invoice_model.dart         # Invoice data model
├── screens/
│   ├── auth/
│   │   └── login_screen.dart      # Login UI
│   ├── dashboard/
│   │   ├── dashboard_screen.dart  # Main dashboard
│   │   └── widgets/
│   │       ├── stat_cards.dart
│   │       ├── fee_trend_chart.dart
│   │       └── academic_calendar.dart
│   ├── students/
│   │   ├── students_screen.dart
│   │   └── widgets/
│   │       ├── student_data_table.dart
│   │       ├── student_search_bar.dart
│   │       └── add_student_dialog.dart
│   ├── invoices/
│   │   ├── invoices_screen.dart
│   │   ├── invoice_detail_screen.dart
│   │   └── widgets/
│   │       ├── invoice_data_table.dart
│   │       └── invoice_summary_cards.dart
│   └── main_layout.dart           # Sidebar navigation
└── main.dart                      # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- A running backend REST API on `http://localhost:5000/api/v1`

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/edustream.git
cd edustream

# 2. Install dependencies
flutter pub get

# 3. Run the app
# For Web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

### Backend API

This app connects to a REST API at:

| Platform | Base URL |
|----------|----------|
| Web | `http://localhost:5000/api/v1` |
| Android Emulator | `http://10.0.2.2:5000/api/v1` |
| iOS / Desktop | `http://localhost:5000/api/v1` |

> Make sure your backend server is running before launching the app.

---

## 🔐 Authentication

The app uses **JWT token-based authentication**. On login, the token is stored locally using `shared_preferences` and sent as a `Bearer` token in all API requests.

---

## 📄 PDF Invoice

EduStream generates professional PDF invoices that include:
- School branding (EduStream header)
- Student details & subscription period
- Fee breakdown with tax
- QR code for verification
- FBR integration badge

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^8.1.0
  fl_chart: ^1.2.0
  pdf: ^3.12.0
  printing: ^5.14.3
  http: ^1.6.0
  intl: ^0.20.2
  shared_preferences: ^2.5.5
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 👨‍💻 Author

Built with ❤️ using Flutter

> Open to internship & job opportunities — feel free to reach out!

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).
