# IndustryX — iOS Equipment Marketplace App

## Описание

IndustryX — мобильное iOS-приложение для аренды и продажи строительной техники. Пользователи могут просматривать каталог оборудования (экскаваторы, краны, генераторы, подъёмники), добавлять позиции в избранное, создавать свои объявления и управлять профилем.

---

## Стек технологий

| Слой | Технология |
|------|-----------|
| Язык | Swift 5.9+ |
| UI Framework | SwiftUI |
| Backend / БД | Firebase Firestore |
| Хранилище файлов | Firebase Storage |
| Аутентификация | Firebase Auth (Email/Password) |
| Зависимости | Swift Package Manager (SPM) |
| Минимальная версия iOS | iOS 16+ |

---

## Зависимости (SPM)

Все зависимости подключены через Swift Package Manager и находятся в `Package.resolved`:

| Пакет | Версия | Назначение |
|-------|--------|-----------|
| `firebase-ios-sdk` | 12.11.0 | Firestore, Auth, Storage |
| `GoogleAppMeasurement` | 12.11.0 | Firebase Analytics |
| `GoogleDataTransport` | 10.1.0 | Транспорт событий Firebase |
| `GoogleUtilities` | 8.1.0 | Утилиты Google SDK |
| `abseil-cpp-binary` | 1.2024072200.0 | Зависимость gRPC |
| `grpc-binary` | 1.69.1 | Зависимость Firestore |
| `leveldb` | 1.22.5 | Локальный кэш Firestore |
| `nanopb` | 2.30910.0 | Сериализация protobuf |
| `promises` | 2.4.0 | Async утилиты Google |
| `app-check` | 11.2.0 | Firebase App Check |

---

## Структура проекта

```
IndustryX/
├── App/
│   └── IndustryXApp.swift          # Точка входа, FirebaseApp.configure()
├── Core/
│   ├── Authentication/             # Firebase Auth, AuthenticationManager
│   ├── Profile/                    # ProfilePageView, ProfilePageViewModel
│   ├── Categories/                 # CategoriesPageView, SecondView, ItemsView
│   ├── Home/                       # HomePageView, AppDataStore
│   ├── Favorites/                  # FavoritesPageView, Favorite (ObservableObject)
│   └── CreateListing/              # CreateListingView, CreateListingViewModel
├── Models/
│   └── CategoriesPageViewModel.swift  # Categories, Subcategory, EquipmentItem, TechnicalSpec
└── MainPageTabBar.swift            # TabView, root navigation
```

---

## Firebase / Firestore структура данных

```
Firestore:
├── categories/                          ← коллекция категорий
│   └── {categoryId}/                   ← документ (name, icon, availableUnits)
│       └── subcategories/              ← подколлекция
│           └── {subcategoryId}/        ← документ (name, tag, description, units, summaryStats, thumbnail)
│               └── items/              ← подколлекция
│                   └── {itemId}        ← документ (все поля EquipmentItem)
│
└── users/                              ← коллекция пользователей
    └── {userId}/                       ← документ (name, surname, email, birthDay, avatarURL)
        └── favorites/                  ← подколлекция избранного
            └── {itemId}               ← документ (копия EquipmentItem)

Firebase Storage:
├── avatars/{userId}.jpg               ← аватары пользователей
└── listings/{listingId}/photo_N.jpg  ← фото объявлений
```

---

## Инструкция по запуску

### Требования
- macOS 13.0+
- Xcode 15.0+
- Активный Apple Developer аккаунт (для запуска на устройстве)
- Firebase проект с включёнными сервисами: **Firestore**, **Storage**, **Authentication**

### Шаги

1. **Клонировать репозиторий**
```bash
git clone https://github.com/nekitan78/IndustryXProject.git
cd IndustryXProject
```

2. **Добавить `GoogleService-Info.plist`**

Скачать файл из Firebase Console → Project Settings → iOS App и положить в корень проекта:
```
IndustryX/GoogleService-Info.plist
```
> ⚠️ Этот файл не хранится в репозитории — он содержит секреты.

3. **Открыть проект в Xcode**
```bash
open IndustryX.xcodeproj
```

4. **SPM зависимости подтянутся автоматически** при первом открытии.

5. **Выбрать симулятор или устройство** и нажать `⌘R`.

---

## Firebase Rules (для разработки)

### Firestore
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

> ⚠️ Перед продакшном правила необходимо ужесточить.

---

## Технические требования

| Параметр | Значение |
|----------|---------|
| Платформа | iOS 16+ |
| Поддерживаемые устройства | iPhone (все размеры) |
| Размер сборки (примерно) | ~80–120 MB (с Firebase SDK) |
| Интернет | Обязателен (Firestore + Storage) |
| Офлайн | Частичный (Firestore локальный кэш через LevelDB) |

---

## Переменные окружения / конфигурация

Приложение не использует `.env` файлы — конфигурация Firebase задаётся через `GoogleService-Info.plist`.

| Параметр | Где задать |
|----------|-----------|
| Firebase API Key | `GoogleService-Info.plist` |
| Firestore Project ID | `GoogleService-Info.plist` |
| Storage Bucket | `GoogleService-Info.plist` |
| Bundle ID | Xcode → Target → General |

---

## Нагрузка и оценка ресурсов

| Метрика | Оценка |
|---------|--------|
| Firestore reads при запуске | ~15–30 (категории + подкатегории + счётчик items) |
| Firestore reads при навигации | ~5–10 на экран items |
| Storage запросов | 1 при загрузке аватара |
| RAM на устройстве | ~60–100 MB (зависит от кол-ва загруженных AsyncImage) |
| Трафик на сессию | ~0.5–2 MB (текст + превью изображений) |

---

## Логи

Логи выводятся в консоль Xcode через `print()`:

| Префикс | Значение |
|---------|---------|
| `✅` | Успешная операция (сохранение, загрузка, upload) |
| `❌` | Ошибка операции |
| `🎉` | Завершение сидирования данных |
| `Error loading...` | Ошибка загрузки из Firestore |

---

## Деплой / сборка для TestFlight

1. Выбрать `Any iOS Device (arm64)` в Xcode
2. `Product → Archive`
3. В Organizer: `Distribute App → TestFlight & App Store`
4. Дождаться обработки в App Store Connect

> Приложение является нативным iOS клиентом и не деплоится на сервер — серверная часть полностью на Firebase.
