# SERA Codebase Instructions for AI Agents

## Project Overview

**SERA** (Smart Emergency Response App) is a Flutter-based mobile application designed to provide real-time first aid guidance and disaster survival instructions during emergencies. The app bridges the critical time gap between incident occurrence and professional responder arrival.

- **Platform**: Flutter (Android primary, iOS/Web/Desktop planned)
- **State Management**: Provider pattern
- **Architecture**: Screen-based navigation with Provider-driven state
- **Language**: Dart + Kotlin (native Android for future sensor integration)
- **Target Locales**: Arabic (ar_AE) primary, English (en_US) secondary with RTL support

## Architecture & Key Components

### Navigation Model
The app uses a **custom stack-based navigation** managed by `NavigationProvider` (`lib/providers/navigation_provider.dart`):

- Maintains a `_pageStack` of `NavigationPage` enum values
- No Go Router currently; manual navigation stack
- Each page is rendered directly by `MainNavigator` switch statement
- Back button behavior: `goBack()` pops the stack; `resetToHome()` clears all and returns home

**Key Pattern**: Always use `navProvider.navigateTo()`, `navigateToFirstAidDetail()`, or `navigateToDisasterDetail()` rather than direct widget navigation.

### Data Models (Static)

**`FirstAidCase`** (`lib/models/first_aid_case.dart`):
- ID, title, description, icon, list of String steps, color
- Predefined cases in `FirstAidData.cases`: CPR, Choking, Fainting, Drowning
- Retrieved via `FirstAidData.getCaseById(String id)`

**`DisasterCase`** (`lib/models/disaster_case.dart`):
- Similar structure but steps are `DisasterStep` objects (icon + text)
- Predefined disasters: Fire, Earthquake, Floods
- Retrieved via `DisasterData.getDisasterById(String id)`

**Why separate models**: First aid steps are simple strings; disaster steps include icons for each step.

### Screen Structure

1. **HomeScreen** (`lib/screens/home_screen.dart`)
   - Responsive layout using `LayoutBuilder` with responsive sizing clamping
   - SOS button always pinned at bottom
   - Two main action buttons: First Aid & Disasters
   - RTL-aware layout alignment

2. **FirstAidScreen** (`lib/screens/first_aid_screen.dart`)
   - 2-column GridView of first aid case cards
   - Tap animation (scale 0.95) on cards

3. **FirstAidDetailScreen** (`lib/screens/first_aid_detail_screen.dart`)
   - Title card with gradient based on case color
   - Numbered steps with icons and descriptions
   - AI Assistant card placeholder at bottom

4. **DisastersScreen** & **DisasterDetailScreen**: Similar structure to first aid screens

5. **SplashScreen** (`lib/screens/splash_screen.dart`): App startup

### SOS System (`lib/widgets/sos_button.dart`)

- **Long-press activation**: 1500ms threshold (haptic feedback on start)
- **Dialog countdown**: 15-second timer with cancel option
- Shows location/emergency contact notification
- No audio currently (removed for build stability; framework in place for restoration)
- Returns to home after successful alert

## Key Design Patterns & Conventions

### Provider Usage

```dart
// Always listen: false for navigation actions
final navProvider = Provider.of<NavigationProvider>(context, listen: false);
navProvider.navigateTo(NavigationPage.firstAid);

// Use Consumer when rebuilding is needed
Consumer<NavigationProvider>(
  builder: (context, navProvider, child) { ... }
)
```

### Theming & Colors

- **Dark theme by default**: `Brightness.dark`, scaffold background `#1F2937`
- **Color system**: Each case/disaster has a `Color` property for gradients and accents
- **Responsive typography**: Use `fontSize` that adapts based on `LayoutBuilder` constraints
- **Gradients**: Applied to main buttons and detail cards for visual hierarchy

### RTL/LTR & Localization

- Default locale: `Locale('ar', 'AE')`
- Back button uses RTL-aware icon: `Icons.arrow_forward` (appears as left arrow in RTL)
- All text is in both Arabic and English comments; Arabic is display default
- Use `textAlign: TextAlign.right` for RTL-safe layouts

### Responsive Design

```dart
// Pattern used in HomeScreen
final maxH = constraints.maxHeight;
final buttonHeight = (maxH * 0.1495).clamp(80.0, 126.0);
// Clamping prevents overflow on very short/tall screens
```

## Development Workflows

### Build & Run

```bash
# Clean build (often needed for Android)
flutter clean
flutter pub get

# Run on device
flutter run

# Run with verbose logging for debugging
flutter run -v

# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Code Quality

- **Analysis**: `flutter analyze` (uses `analysis_options.yaml` - linting is minimal/commented out)
- **No test files yet** in project; testing infrastructure exists in `test/` directory but is unused
- **Lint violations**: Mostly commented out; add rules as needed to `analysis_options.yaml`

### State Inspection

- Use `Provider DevTools` extension in VS Code for state debugging
- Check `NavigationProvider._pageStack` to verify navigation stack
- Examine `selectedFirstAidCase` / `selectedDisaster` when debugging detail screens

## Critical Dependencies & Future Integrations

### Current Dependencies

- `flutter`, `flutter_localizations`: Core & localization
- `provider: ^6.1.1`: State management
- `go_router: ^12.1.3`: Declared but not used; consider for future routing refactor
- `intl: ^0.20.2`: Localization support
- `cupertino_icons: ^1.0.6`: iOS-style icons

### Removed/Disabled

- `audioplayers`: Removed to restore build stability; audio logic gutted in `SosButton` & dialogs
- Framework remains for future restoration (TODO comments present)

### Future Integrations (Planned)

- **TensorFlow Lite**: On-device AI for case selection
- **Camera integration**: Risk detection (smoke, fire, blocked exits)
- **Sensor fusion**: Accelerometer, gyroscope for fall/crash detection
- **Kotlin native**: Low-level sensor access for Android
- **Wearables**: Heart rate, SpO₂ integration

## Important Implementation Notes

1. **No persistence layer yet**: All data is in-memory; cases are hardcoded in model classes
2. **Location services**: SOS button references location but implementation is placeholder
3. **Emergency contacts**: SOS dialog mentions emergency contacts but doesn't yet integrate
4. **Audio feedback**: Removed for stability; re-enable via `audioplayers` when stable
5. **Haptic feedback**: Uses `HapticFeedback` from Flutter; fully functional for SOS interactions
6. **Navigation state loss**: Stack is cleared on app backgrounding; consider persisting for production

## Common Tasks & Examples

### Add a New First Aid Case

1. Add constant to `FirstAidData.cases` in `lib/models/first_aid_case.dart`
2. Define icon (from `Icons`), color, and steps (list of String)
3. Case auto-appears in FirstAidScreen grid
4. Tap navigation and detail rendering are automatic

### Add a New Disaster

1. Add `DisasterCase` to `DisasterData.disasters` in `lib/models/disaster_case.dart`
2. Define `DisasterStep` objects (each with icon + text)
3. Similar auto-integration as first aid

### Modify SOS Behavior

- Edit `SosButton` class for tap/press logic
- Edit `SosDialog` for countdown/confirmation flow
- Restore audio: Uncomment `audioplayers` package, import, and method calls

### Change App Locale

- Modify `locale` in `SeraEmergencyApp.build()` `MaterialApp` constructor
- RTL mode auto-adjusts layouts using `textAlign` and icon direction

## Debugging Tips

- **Navigation loops**: Check `NavigationProvider._pageStack` for duplicates
- **Layout overflow**: Use `LayoutBuilder` constraints and clamping; check `SafeArea` nesting
- **Black screens**: Ensure `MainNavigator.build()` switch handles all `NavigationPage` cases
- **Locale not applied**: Verify `locale` and `supportedLocales` in `MaterialApp`
- **SOS not firing**: Check 1500ms long-press timer in `SosButton._onLongPressStart()`

## Conventions Summary

- Use **Provider** for all state management (no Riverpod/Bloc)
- Navigation via **stack-based custom router**, not Go Router
- **Dark theme** by default; no light mode currently
- **RTL-first** design (Arabic primary); LTR supported
- **No external backends** (currently); all data static in models
- **Minimal linting** (most rules commented); can expand per team needs
- **Responsive layouts** via `LayoutBuilder` with clamped values
