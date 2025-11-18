# Adda Gold - Flutter App

Adda Gold is a Flutter learning companion app for Android and iOS featuring a swipeable feed of quizzes and micro-learning reels. Optimized for one-handed (thumb) use.

## Features

- **Quiz Feed**: Vertical swipeable quiz cards with instant feedback, haptics, explanations, and thumb shortcuts
- **Reels Feed**: Fullscreen vertical videos with autoplay, mute toggle, like/bookmark/share actions
- **Profile**: Stats tracking (accuracy, streaks, time spent) and customizable settings
- **Offline-first**: Local storage for progress, bookmarks, and preferences
- **Theme Support**: Light/dark mode with system theme detection

## Tech Stack

- Flutter 3.0+
- State Management: Riverpod + Hooks
- Video: `video_player` + `chewie`
- Storage: `shared_preferences`
- Navigation: Material 3 NavigationBar

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile builds)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Run on Specific Ports

To run on ports 3456 (web) and 5678 (mobile):

```bash
# Mobile (default)
flutter run

# Web on port 3456
flutter run -d chrome --web-port=3456

# Or use any available device
flutter devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
  models/          # Data models (QuizItem, ReelItem, etc.)
  services/        # DataService, StorageService
  providers/       # Riverpod providers (Quiz, Reel, Settings)
  screens/         # HomeScreen, QuizFeedScreen, ReelFeedScreen, ProfileScreen
  widgets/         # Reusable widgets (QuizCard, ReelCard, ThumbBar, etc.)
  theme/           # AppTheme (light/dark)
assets/
  quizzes.json     # Mock quiz data
  reels.json       # Mock reel data
```

## Data Models

- `QuizItem`: Quiz question with options and correct answer
- `ReelItem`: Video reel with metadata
- `QuizProgress`: User's answer and performance data
- `FeedProgress`: Overall stats (streak, accuracy, time spent)

## State Management

Uses Riverpod for state management:
- `quizProvider`: Manages quiz state, answers, bookmarks, stats
- `reelProvider`: Manages reel state, likes, bookmarks, mute status
- `settingsProvider`: User preferences (haptics, sound, auto-advance delay)

## Future Enhancements

- Connect to Supabase/Firestore backend
- Download videos for offline viewing
- Push notifications for daily quizzes
- Social features (leaderboards, sharing)
- More quiz categories and difficulty levels

## License

Private project - All rights reserved
