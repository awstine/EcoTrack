# EcoTrack 🌍♻️

A smart waste management Flutter application designed to help users track, manage, and optimize waste disposal through location-based services and interactive mapping.

## Overview

EcoTrack is a cross-platform mobile application built with Flutter that enables users to efficiently manage waste by locating nearby waste management facilities, tracking collection points, and promoting sustainable practices through an intuitive interface.

## Features

- 📍 **GPS-Enabled Location Tracking** - Real-time geolocation services using the Geolocator package
- 🗺️ **Interactive Mapping** - View waste facilities and collection points on an interactive map with Flutter Map
- 📸 **Image Capture** - Take and store images of waste areas using the device camera
- 🔍 **Geocoding Support** - Convert coordinates to addresses and vice versa
- 💾 **Local Data Persistence** - Save user preferences and data locally with Shared Preferences
- 🌐 **API Integration** - Connect to backend services for real-time data synchronization
- 📋 **Tile Caching** - Efficient map tile caching for offline-capable mapping
- 🔗 **URL Launcher** - Quick access to external resources and contact information

## Technology Stack

- **Framework**: Flutter (Dart)
- **Minimum SDK**: Dart 3.0.0+
- **Target Platforms**: iOS, Android, Web

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_map` | ^6.1.0 | Interactive mapping interface |
| `geolocator` | ^11.0.0 | GPS and location services |
| `image_picker` | ^1.1.2 | Camera and gallery integration |
| `shared_preferences` | ^2.2.2 | Local data persistence |
| `geocoding` | ^2.1.1 | Address/coordinates conversion |
| `http` | ^1.4.0 | HTTP requests for API calls |
| `latlong2` | ^0.9.1 | Geographic coordinate handling |
| `flutter_map_tile_caching` | ^9.0.1 | Map tile caching |
| `url_launcher` | ^6.2.1 | External link handling |

## Project Structure

```
EcoTrack/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── models/                # Data models and entities
│   ├── screens/               # UI screens and pages
│   ├── services/              # Business logic and API services
│   ├── utils/                 # Utility functions and helpers
│   └── widgets/               # Reusable UI components
├── android/                   # Android-specific configurations
├── ios/                       # iOS-specific configurations
├── web/                       # Web-specific configurations
├── pubspec.yaml               # Flutter project configuration
└── analysis_options.yaml      # Dart analysis rules
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- iOS 11.0+ or Android API 21+

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/awstine/EcoTrack.git
   cd EcoTrack
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Ensure you have Android SDK and Build Tools installed
- For location services, add permissions to `android/app/src/main/AndroidManifest.xml`

#### iOS
- Requires Xcode installed
- For location and camera services, configure privacy permissions in `ios/Runner/Info.plist`

#### Web
- Run with: `flutter run -d chrome`

## Configuration

### Location Permissions

The app requires location permissions to function. Ensure these are properly configured:
- **iOS**: Add location permissions to `Info.plist`
- **Android**: Add location permissions to `AndroidManifest.xml`

### Camera Permissions

For image capture functionality:
- **iOS**: Add camera and photo library permissions to `Info.plist`
- **Android**: Add camera permission to `AndroidManifest.xml`

## API Integration

EcoTrack connects to backend services for waste facility data and user analytics. Configure your API endpoints in the services layer (typically in `lib/services/`).

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Development

### Code Analysis
```bash
flutter analyze
```

### Testing
```bash
flutter test
```

### Building Documentation
```bash
dartdoc
```

## Contributing

We welcome contributions to EcoTrack! Please feel free to:
- Report bugs and issues
- Suggest new features
- Submit pull requests with improvements
- Improve documentation

## License

This project is open source and available under the MIT License.

## Support

For help and questions:
- 📖 [Flutter Documentation](https://flutter.dev/docs)
- 📚 [Dart Documentation](https://dart.dev/guides)
- 💬 [FlutLab Community](https://flutlab.io/residents)

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Developed using [FlutLab - Flutter Online IDE](https://flutlab.io)
- Uses open-source Flutter packages and libraries

---

**Last Updated**: May 2026  
**Repository**: [awstine/EcoTrack](https://github.com/awstine/EcoTrack)
