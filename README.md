# ImageFeed

[Russian version below](#russian)

# English
## Overview

**ImageFeed** is a UIKit‑based iOS app that shows a photo feed from **Unsplash**. Users sign in via OAuth, scroll an infinite feed, like/unlike photos, open a full‑screen viewer with zoom, see their profile, and log out.

- Minimum iOS: **13.0**
- Language: **Swift**
- UI: **UIKit + Storyboards**
- Dependencies (Swift Package Manager):
  - **Kingfisher** — Image downloading & caching
  - **SwiftKeychainWrapper** — Secure token storage in Keychain
  - **ProgressHUD** — Loading HUD

## Features

- 🔐 OAuth2 login in a WebView (Unsplash)
- 📰 Infinite scroll photo feed (paged loading)
- ❤️ Like/Unlike with optimistic UI
- 🔎 Full‑screen photo viewer with zoom/pan
- 👤 Profile screen: name, handle, bio, avatar
- ↩️ Logout (token cleared from Keychain)
- 🧊 Image caching and smooth loading

## Architecture

Pattern: **MVC + Service Layer**

- **Presentation (UIKit)**: view controllers (`AuthViewController`, `ImagesListViewController`, `SingleImageViewController`, `ProfileViewController`, `SplashViewController`, `TabBarController`)
- **Services**: networking + business logic (`OAuth2Service`, `ImagesListService`, `ProfileService`, `ProfileImageService`)
- **Models**: DTOs & UI models (`PhotoResult`, `Photo`, `Photos`, `ProfileResult`, `Profile`)
- **Infrastructure**: token storage (`OAuth2TokenStorage`), `URLSession` helpers, blocking HUD
- **Navigation**: starts at `SplashViewController`, then auth or tab bar

### Project layout

```
See the structure above (RU section) — folders and files are identical.
```

## Networking & API

- Base URL: `https://api.unsplash.com`
- `URLSession+data.swift` provides:
  - `data(for:completion:)` — wrapper delivering results on main thread with error mapping
  - `objectTask(for:completion:)` — generic decoding into `Decodable`
- Key endpoints:
  - `POST /oauth/token` — exchange code for token (`OAuth2Service`)
  - `GET /me` — current user profile (`ProfileService`)
  - `GET /users/:username` — avatar (`ProfileImageService`)
  - `GET /photos?page=N` — feed (`ImagesListService`)
  - `POST/DELETE /photos/:id/like` — like/unlike (`ImagesListService`)

## Dependencies

- **Kingfisher** — image downloading/caching
- **SwiftKeychainWrapper** — secure bearer token storage
- **ProgressHUD** — blocking progress HUD via `UIBlockingProgressHUD`

## Getting started

1. **Xcode 15+**, iOS 13.0+
2. Create an app in **Unsplash Developers** and obtain **Access Key** and **Secret Key**
3. Put the keys into `Constants.swift`:
   ```swift
   enum Constants {{
       static let accessKey = "<YOUR_ACCESS_KEY>"
       static let secretKey = "<YOUR_SECRET_KEY>"
       static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
       static let accessScope = "public+read_user+write_user+write_likes"
       static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
   }}
   ```
4. Open `ImageFeed.xcodeproj`, resolve SPM packages, run in Simulator.

> 💡 **Security**: don’t commit real secrets. Prefer `.xcconfig`/User‑Defined Settings or CI secrets.

## Error handling

- Unified `NetworkError` for low‑level issues
- HTTP status + response body logging for diagnostics
- User‑facing alerts on auth/profile/load/like failures

## Local build

- Bundle Identifier: `vladimir.ImageFeed` (change in Target settings)
- Schemes: Debug/Release

## Roadmap

- Unit tests for services (mock `URLProtocol`)
- Feed/profile caching and offline mode
- DI container and modules
- Move secrets out of `Constants.swift`
- Adopt Swift Concurrency (async/await)

## License

Add a LICENSE file (e.g., MIT) when publishing.

# Russian

## Описание

**ImageFeed** — это iOS‑приложение на UIKit, которое показывает ленту фотографий из **Unsplash**. Пользователь проходит OAuth‑авторизацию, просматривает бесконечную ленту, ставит/снимает лайки, открывает фото на весь экран с масштабированием, видит профиль и может выйти из аккаунта.

- Минимальная iOS: **13.0**
- Язык: **Swift**
- UI: **UIKit + Storyboards**
- Зависимости (Swift Package Manager):
  - **Kingfisher** — Загрузка и кеширование изображений / Image downloading & caching
  - **SwiftKeychainWrapper** — Хранение токена в Keychain / Secure token storage in Keychain
  - **ProgressHUD** — Индикатор загрузки / Loading HUD

## Возможности

- 🔐 OAuth2 авторизация через WebView (Unsplash)
- 📰 Лента фото с подгрузкой по страницам (infinite scroll)
- ❤️ Лайк/анлайк фото (оптимистичное обновление кнопки)
- 🔎 Просмотр отдельного фото с zoom/pan
- 👤 Экран профиля: имя, логин, био, аватар
- ↩️ Выход из аккаунта (очистка токена из Keychain)
- 🧊 Кеширование изображений и плавная подгрузка

## Архитектура

Проект построен как **MVC + Service Layer**:

- **Presentation (UIKit)**: контроллеры экранов (`AuthViewController`, `ImagesListViewController`, `SingleImageViewController`, `ProfileViewController`, `SplashViewController`, `TabBarController`).
- **Services**: работа с сетью и бизнес‑логикой (`OAuth2Service`, `ImagesListService`, `ProfileService`, `ProfileImageService`).
- **Models**: DTO и UI‑модели (`PhotoResult`, `Photo`, `Photos`, `ProfileResult`, `Profile`).
- **Infrastructure**: хранение токена (`OAuth2TokenStorage`), расширения `URLSession`, индикатор `UIBlockingProgressHUD`.
- **Навигация**: старт со `SplashViewController`, далее — авторизация или `UITabBarController`.

## Сеть и API

- Базовый URL: `https://api.unsplash.com`
- Расширение `URLSession+data.swift` даёт:
  - `data(for:completion:)` — обёртка над `URLSession` с доставкой результата на main‑поток и маппингом ошибок
  - `objectTask(for:completion:)` — дженерик‑декодер в `Decodable` модель
- Основные эндпоинты:
  - `POST /oauth/token` — обмен кода на токен (`OAuth2Service`)
  - `GET /me` — профиль текущего пользователя (`ProfileService`)
  - `GET /users/:username` — аватар (`ProfileImageService`)
  - `GET /photos?page=N` — лента (`ImagesListService`)
  - `POST/DELETE /photos/:id/like` — лайк/дизлайк (`ImagesListService`)

## Авторизация (OAuth 2.0)

- Экран `WebViewViewController` открывает `{{unsplash}}/oauth/authorize` c параметрами из `Constants.swift`
- Перехват кода по схеме `.../oauth/authorize/native?code=...`
- `OAuth2Service.fetchOAuthToken(code:)` меняет код на токен и сохраняет в `Keychain` через `OAuth2TokenStorage`
- `SplashViewController` решает, показывать авторизацию или главный таббар

## Зависимости

- **Kingfisher** — загрузка/кеш изображений в `ImagesListViewController`, `ProfileViewController`
- **SwiftKeychainWrapper** — безопасное хранение Bearer‑токена
- **ProgressHUD** — блокирующий HUD через `UIBlockingProgressHUD`

## Требования и запуск

1. **Xcode 15+**, iOS 13.0+
2. Создайте приложение в **Unsplash Developers** и получите **Access Key** и **Secret Key**
3. Вставьте ключи в `Constants.swift`:
   ```swift
   enum Constants {{
       static let accessKey = "<YOUR_ACCESS_KEY>"
       static let secretKey = "<YOUR_SECRET_KEY>"
       static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
       static let accessScope = "public+read_user+write_user+write_likes"
       static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
   }}
   ```
4. Откройте `ImageFeed.xcodeproj`, дождитесь загрузки пакетов SPM и запустите на симуляторе.

> 💡 **Безопасность**: не храните реальные ключи в репозитории. Вынесите их в `.xcconfig`/User‑Defined Settings или используйте секреты CI.

## UI и UX

- Таблица с авто‑изменением высоты ячеек, placeholder‑картинки и HUD при критических операциях
- Открытие фото в полноэкранный контроллер с жестами зума/прокрутки
- Оптимистичное обновление состояния лайка; при ошибке — возврат и алерт

## Обработка ошибок

- Единый `NetworkError` для низкоуровневых ошибок
- Логи HTTP‑статуса с телом ответа для диагностики
- Пользовательские алерты на авторизации/загрузке профиля/лайке

## Локальная сборка

- Bundle Identifier: `vladimir.ImageFeed` (можно поменять в настройках Target)
- Схемы: Debug/Release с одинаковыми фичами

## Дальнейшие улучшения

- Добавить модульные тесты сервисов (моки URLProtocol)
- Кэш профиля и оффлайн для ленты
- DI‑контейнер и разделение на модули
- Отделить секреты из `Constants.swift` в `.xcconfig`
- Swift Concurrency (async/await) вместо completion‑блоков

## Лицензия

Добавьте файл LICENSE (например, MIT) при публикации.

---

### Credits

- Unsplash API and brand assets
- Libraries: Kingfisher, SwiftKeychainWrapper, ProgressHUD
