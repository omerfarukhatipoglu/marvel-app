# marvel

lib/
├── consts/              # Sabitler ve yardımcı bileşenler
│   ├── layout_helper.dart
│   └── no_internet_dialog.dart
├── controllers/         # GetX controller dosyaları
│   ├── favourite_controller.dart
│   ├── main_controller.dart
│   └── profile_controller.dart
├── modules/             # Veri modelleri
│   └── character.dart
├── pages/               # Ekran dosyaları (UI)
│   ├── favourite_page.dart
│   ├── main_page.dart
│   ├── profile_page.dart
│   └── splash_page.dart
├── routes/              # Sayfa yönlendirme yapısı
│   ├── pages.dart
│   └── routes.dart
├── services/            # API ve yerel verilerle ilgili servisler
│   ├── favourite_service.dart
│   └── my_api.dart
└── main.dart            # Uygulama başlangıç noktası
