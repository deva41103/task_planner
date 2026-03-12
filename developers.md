# Developer Documentation - Coderower (Daily Health Tracker)

This document provides a detailed overview of the project's technical architecture, file structure, and dependencies.

## Project Overview
**Coderower** is a "Daily Health Tracker" application built using Flutter. It allows users to track their daily steps, log activities, and receive daily health tips.

## Technology Stack
- **Framework:** Flutter
- **State Management & Routing:** [GetX](https://pub.dev/packages/get)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Animations:** [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Image Caching:** [cached_network_image](https://pub.dev/packages/cached_network_image)

---

## Folder Structure (`lib/`)

### 1. Controllers (`lib/controllers/`)
Business logic and state management using GetX.
- **[activity_controller.dart](file:///d:/Flutter/coderower/lib/controllers/activity_controller.dart)**: Manages activity logs, including lazy loading/pagination and adding new logs.
  - *Connections*: Uses `FirestoreService`. Consumed by `DashboardView` and `ActivityLogsView`.
- **[health_controller.dart](file:///d:/Flutter/coderower/lib/controllers/health_controller.dart)**: Manages weekly health data, health tips, and a countdown timer.
  - *Connections*: Uses `FirestoreService` and `HealthTipService`. Consumed by `DashboardView`.
- **[login_controller.dart](file:///d:/Flutter/coderower/lib/controllers/login_controller.dart)**: Handles the UI state for the login process.
  - *Connections*: Uses `AuthService`. Consumed by `LoginView`.

### 2. Models (`lib/models/`)
Data structures and serialization.
- **[health_models.dart](file:///d:/Flutter/coderower/lib/models/health_models.dart)**: Defines `HealthData` and `ActivityLog` classes with `fromJson` and `toMap` methods.
  - *Connections*: Used throughout the app by services, controllers, and views.

### 3. Routes (`lib/routes/`)
Application navigation configuration.
- **[app_routes.dart](file:///d:/Flutter/coderower/lib/routes/app_routes.dart)**: Defines route names and the list of `GetPage` objects.
  - *Connections*: Referenced in `main.dart` and used for navigation in views/controllers.

### 4. Services (`lib/services/`)
Data fetching and external integrations.
- **[api_service.dart](file:///d:/Flutter/coderower/lib/services/api_service.dart)**: Generic API service (placeholder/utility).
- **[auth_service.dart](file:///d:/Flutter/coderower/lib/services/auth_service.dart)**: Manages Google Sign-In and Firebase Authentication. Handles auto-navigation based on auth state.
  - *Connections*: Used by `LoginController` and `main.dart`.
- **[firestore_service.dart](file:///d:/Flutter/coderower/lib/services/firestore_service.dart)**: Handles all Firestore operations for health data and activity logs.
  - *Connections*: Used by `ActivityController` and `HealthController`.
- **[health_tip_service.dart](file:///d:/Flutter/coderower/lib/services/health_tip_service.dart)**: Fetches a "Daily Tip" from a mock REST API (JSONPlaceholder).
  - *Connections*: Used by `HealthController`.

### 5. Views (`lib/views/`)
UI implementation (Screens).
- **[activity_logs_view.dart](file:///d:/Flutter/coderower/lib/views/activity_logs_view.dart)**: Displays a scrollable list of activity logs with lazy loading.
  - *Connections*: Uses `ActivityController`.
- **[dashboard_view.dart](file:///d:/Flutter/coderower/lib/views/dashboard_view.dart)**: The main user interface showing the graph, health tip, and timer.
  - *Connections*: Uses `HealthController`, `ActivityController`, and `AuthService`.
- **[login_view.dart](file:///d:/Flutter/coderower/lib/views/login_view.dart)**: The entry screen for authentication.
  - *Connections*: Uses `LoginController`.

### 6. Widgets (`lib/widgets/`)
Reusable UI components.
- **[custom_widgets.dart](file:///d:/Flutter/coderower/lib/widgets/custom_widgets.dart)**: Common UI elements like `CustomCard` and `AnimatedScaleButton`.
- **[fade_in_animation.dart](file:///d:/Flutter/coderower/lib/widgets/fade_in_animation.dart)**: A wrapper widget for adding fade-in effects to UI elements.
- **[step_graph.dart](file:///d:/Flutter/coderower/lib/widgets/step_graph.dart)**: Implements the weekly progress line chart using `fl_chart`.

---

## Architecture Flow
1. **App Initialization**: `main.dart` initializes Firebase, loads `.env`, and registers services in `InitialBinding`.
2. **Authentication**: `AuthService` listens to Firebase auth changes. If logged in, it redirects to `/dashboard`, otherwise to `/login`.
3. **Data Management**: Controllers (GetX) fetch data via Services (Firestore/API).
4. **Reactive UI**: Views use `Obx` or `GetView` to automatically update when Controller observables change.
