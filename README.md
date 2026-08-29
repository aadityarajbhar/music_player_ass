# Jamendo Music Player App 🎵

A clean, modern, and production-grade Flutter Music Player application built using **GetX** for state management, **Jamendo API** for music streaming, **just_audio** for playback, and **GetStorage** for offline caching.

---

## 🚀 Features

- **Modern Dark UI/UX**: Aesthetic glassmorphism dark theme tuned for music applications.
- **Jamendo API Integration**: Fetch tracks with title, artist, duration, album artwork, and streaming audio.
- **Infinite Scroll Pagination**: Automatically loads the next page of songs when scrolling near the bottom with loading indicator, preventing duplicate requests and managing list boundaries.
- **Live Search**: Instant track and artist search with clear action and debounced query execution.
- **Audio Player Controls**:
  - Full-screen Now Playing screen with album art hero animation.
  - InteractiveSeek / Progress Bar with live position and duration timestamps.
  - Play, Pause, Previous, Next controls.
  - Shuffle and Repeat track toggles.
- **Mini Player**: Floating bottom bar anchored across screens, showing active track thumbnail, play/pause controls, and top progress bar. Tapping opens full Now Playing UI.
- **Offline Fallback Caching**: Automatic local storage of tracks (`GetStorage`). If offline or network fails, cached tracks load gracefully.
- **State Handling**: Comprehensive UI states for Loading, Error with Retry button, and Empty search states.

---

## 🛠️ Architecture & State Management

This application follows the **GetX MVC/MVVM Architectural Pattern** tailored for maintainability, clean separation of concerns, and high testability:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # API base URL, client ID, endpoint configs
│   │   └── app_colors.dart         # Theme color palette
│   ├── theme/
│   │   └── app_theme.dart          # Dark theme specification
│   └── services/
│       └── storage_service.dart     # GetStorage instance for offline caching
├── data/
│   ├── models/
│   │   └── track_model.dart        # Track data model & JSON serialization
│   └── providers/
│       └── jamendo_api_provider.dart# HTTP API requests & error mapping
├── controllers/
│   ├── track_controller.dart       # State management for listing, pagination, search
│   └── player_controller.dart      # State management for just_audio player streams
├── views/
│   ├── home/
│   │   └── home_screen.dart        # Main music feed & pagination view
│   ├── search/
│   │   └── search_screen.dart      # Track search screen
│   ├── player/
│   │   └── now_playing_screen.dart # Fullscreen audio player & controls
│   └── widgets/
│       ├── mini_player.dart        # Anchored bottom mini player bar
│       ├── track_tile.dart         # Reusable list item UI tile
│       ├── seek_bar.dart           # Custom audio progress & seek slider
│       └── state_widgets.dart      # Loading, Error, Empty state components
├── bindings/
│   └── initial_binding.dart        # GetX Dependency Injection setup
└── main.dart                       # App entry point
```

### Key GetX Elements Used:
1. **Controllers (`GetxController`)**:
   - `TrackController`: Handles track fetching, offset-based pagination (`limit=20`), search query updates, and offline fallback.
   - `PlayerController`: Listens to `just_audio` streams (`playerStateStream`, `positionStream`, `durationStream`) and exposes reactive state via Rx observables (`isPlaying`, `position`, `duration`, `currentTrack`).
2. **Reactive UI (`Obx`)**: Fine-grained reactive rebuilding without unnecessary full widget tree redraws.
3. **Dependency Injection (`Get.put` / `Get.find`)**: Centralized instance management via `InitialBinding`.

---

## 🔐 API Configuration & Security

The app uses the official Jamendo API v3.0:
- **Base URL**: `https://api.jamendo.com/v3.0`
- **Default Client ID**: `bc66595a`

### Running with Custom Client ID (Non-Hardcoded / Environment Variable):
Per security best practices, the API Client ID is not hardcoded directly in logic and can be supplied at build/run time via `--dart-define`:

```bash
flutter run --dart-define=JAMENDO_CLIENT_ID=your_client_id_here
```

If no `--dart-define` flag is supplied, the app automatically falls back to the configured default Client ID in `lib/core/constants/api_constants.dart`.

---

## 💻 Prerequisites & Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.29.0 or compatible)
- [Dart SDK](https://dart.dev/get-started) (v3.7.0 or higher)
- Android Studio / VS Code with Flutter extension
- Android device or emulator for testing

### Step 1: Clone Repository
```bash
git clone <your-repository-url>
cd music_player
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run Analysis Check
```bash
flutter analyze
```

### Step 4: Run Application
```bash
# Run on connected Android device/emulator
flutter run
```

---

## 📦 Building Android Release APK

To generate the standalone APK file:

```bash
flutter build apk --release
```

The compiled APK will be located at:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📋 Technical Requirements Checklist

| Requirement | Implementation Status |
| :--- | :--- |
| **Home / Music Listing** | ✅ Implemented with custom song tiles & status indicators |
| **Song Artwork & Info** | ✅ Cached artwork loading with placeholder fallback |
| **Search Functionality** | ✅ Full search screen with live query execution |
| **Now Playing Screen** | ✅ Fullscreen UI with hero image & custom Seek Bar |
| **Mini Player** | ✅ Anchored bottom bar with top progress line |
| **Responsive Layout** | ✅ Adaptive padding, media queries & flex layouts |
| **API Integration** | ✅ Jamendo API endpoints `/tracks` with error handling |
| **Pagination** | ✅ Limit (20) & Offset with duplicate request prevention |
| **Audio Playback** | ✅ Play, Pause, Next, Previous, Seek, Duration, Position |
| **GetX State Management** | ✅ Clean controllers, bindings & reactive `Obx` views |
| **Offline Caching (Bonus)** | ✅ Integrated using `GetStorage` |
