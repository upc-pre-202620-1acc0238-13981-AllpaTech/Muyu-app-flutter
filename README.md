# Muyu (Flutter)

Cross-platform mobile app for **Muyu**, by team **AllpaTech** (UPC, course 1ACC0238, period 202620, NRC 13981).
Farmers publish plots and merchants fund them in escrow, releasing money per milestone
(planting, irrigation, fertilization, harvest) after the evidence is approved.

This is the Flutter version of the native Kotlin/Jetpack Compose app, which is the reference for
screens, texts, colors and flows.

## Stack

- Flutter 3.47 / Dart 3.13, Material 3
- State management and DI: [Riverpod](https://riverpod.dev)
- Navigation: [go_router](https://pub.dev/packages/go_router), with redirects driven by the session
- HTTP: `package:http` against the team backend (`https://muyu-backend-production.up.railway.app/api/v1/`)
- i18n: `flutter gen-l10n` with English (default) and Latin American Spanish (`es_419`)
- Local storage: `shared_preferences` (session, language, per-user settings)

## Run it

```bash
flutter pub get
flutter run
```

To use another backend (for example a local one), pass its base URL:

```bash
flutter run --dart-define=MUYU_API_URL=https://example.com/api/
```

## Project structure

Folders follow the bounded contexts of the Kotlin app. Each feature keeps its own
`domain`, `application`, `infrastructure` and `presentation` layers.

```
lib/
  app.dart                 MaterialApp.router, theme and locales
  main.dart                Loads preferences and starts ProviderScope
  core/
    designsystem/          Shared widgets (auth sheet, fields, buttons, language toggle)
    environment/           API base URL and timeouts
    i18n/                  App language (EN / ES-419), remembered between launches
    network/               JSON API client
    router/                Routes and session-aware redirects
    storage/               SharedPreferences and per-user preferences
    theme/                 Muyu colors, fonts (Urbanist, Fredoka) and ThemeData
  features/
    user_management/       Splash, login, register, role selection, session
    plot_approval/         Farmer side: home (my plots)
    plot_financing/        Merchant side: plot catalog
  l10n/                    app_en.arb, app_es.arb, app_es_419.arb (+ generated code)
```

New users start empty: the app never seeds sample accounts, plots, cards or wallets.

## Tests

```bash
flutter analyze
flutter test
```

## Git workflow

We use GitFlow and Conventional Commits (in English).

- Work happens on `feature/<name>` branches created from `develop`.
- Each feature is merged into `develop` through a pull request.
- `main` is only updated from `develop` for releases; nobody commits to it directly.

Commit examples: `feat(user-management): add role selection`, `fix(router): keep splash while restoring`.
