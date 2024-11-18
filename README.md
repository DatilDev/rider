# LightningRide

A decentralized rideshare platform built with Elixir/Phoenix, using Lightning Network for payments and Nostr for authentication.

## 🚀 Features

- **Decentralized Authentication**
  - Login via Nostr protocol (NIP-07)
  - Support for Amber and other Nostr extensions
  - Hardware key compatibility

- **Secure Payments**
  - Lightning Network integration
  - HTLC-based payment escrow
  - Real-time driver tipping
  - Automatic payment release upon ride completion

- **Real-time Tracking**
  - Live location updates
  - Route visualization
  - ETA calculations
  - Driver-passenger matching

- **Dynamic Pricing**
  - Local gas price integration
  - Distance-based calculation
  - Automatic fare adjustments
  - Transparent price breakdown

## 🛠 Prerequisites

- Elixir ~> 1.14
- Phoenix ~> 1.7.0
- PostgreSQL 12+ with PostGIS extension
- Node.js 16+
- Lightning Network daemon (LND)
- Redis (optional, for production PubSub)

## 💻 Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/your-org/lightning_ride.git
cd lightning_ride
```

2. **Set up environment variables**
```bash
export LND_URL=https://your-lnd-node:8080
export LND_MACAROON=your_macaroon_here
export COLLECT_API_KEY=your_collect_api_key
export SECRET_KEY_BASE=$(mix phx.gen.secret)
```

3. **Install dependencies**
```bash
# Install Elixir deps
mix deps.get

# Install Node.js deps
cd assets && npm install && cd ..
```

4. **Setup database**
```bash
# Create and migrate database
mix ecto.setup
```

5. **Start the server**
```bash
mix phx.server
```

Now visit [`localhost:4000`](http://localhost:4000) in your browser.

## 🧪 Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/lightning_ride/rides_test.exs

# Run tests with coverage report
mix test --cover
```

## 🚢 Deployment

### Using Docker

1. Build the image:
```bash
docker build -t lightning_ride .
```

2. Run the container:
```bash
docker run -p 4000:4000 \
  -e DATABASE_URL=ecto://USER:PASS@HOST/DATABASE \
  -e SECRET_KEY_BASE=your_secret_key \
  -e LND_URL=your_lnd_url \
  -e LND_MACAROON=your_macaroon \
  lightning_ride
```

### Manual Deployment

1. Build release:
```bash
MIX_ENV=prod mix release
```

2. Deploy to server:
```bash
# Copy release to server
scp _build/prod/rel/lightning_ride.tar.gz user@your-server:~

# Extract and run
ssh user@your-server
tar xzf lightning_ride.tar.gz
./bin/lightning_ride start
```

## 📚 Documentation

Generate documentation:
```bash
mix docs
```

View complete documentation in `doc/index.html`

## 🔧 Configuration

Key configuration files:
- `config/config.exs` - Base configuration
- `config/dev.exs` - Development settings
- `config/prod.exs` - Production settings
- `config/runtime.exs` - Runtime configuration

## 🌍 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection URL | Yes |
| `SECRET_KEY_BASE` | Phoenix secret key | Yes |
| `LND_URL` | Lightning Node URL | Yes |
| `LND_MACAROON` | LND authentication macaroon | Yes |
| `COLLECT_API_KEY` | Gas price API key | Yes |
| `PHX_HOST` | Production host | Production only |
| `PORT` | HTTP port | No (default: 4000) |

## 🛣️ API Routes

```elixir
# User authentication
POST /auth/login

# Rides
GET    /api/rides
POST   /api/rides
GET    /api/rides/:id
POST   /api/rides/:id/accept
POST   /api/rides/:id/complete
POST   /api/rides/:id/tip

# Location updates
WS /socket/websocket
```

## 🔐 Security

- All sensitive data is encrypted at rest
- HTTPS required in production
- Rate limiting on authentication endpoints
- Payment security via Lightning Network HTLCs
- Regular security audits

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📫 Support

For support, email support@lightningride.com or join our [Discord community](https://discord.gg/lightningride).

## 🙏 Acknowledgments

- Lightning Network developers
- Nostr protocol contributors
- Phoenix Framework team
- PostGIS contributors

# LightningRide Mobile App

A Flutter-based mobile application for the LightningRide decentralized rideshare platform. Built with privacy in mind, using Lightning Network for payments and Nostr for authentication.

## 📱 Features

- **Native Android Experience**
  - Smooth, native performance
  - Background location tracking
  - Push notifications
  - Offline capabilities
  - Google Maps integration

- **Decentralized Authentication**
  - Nostr protocol integration
  - Hardware key support
  - Secure key storage
  - Simple one-click login

- **Real-time Features**
  - Live ride tracking
  - Driver-passenger chat
  - Location updates
  - Price estimates
  - ETA calculations

- **Lightning Payments**
  - In-app Lightning wallet
  - Quick tipping
  - Payment history
  - QR code scanning
  - Multiple wallet support

## 🛠️ Prerequisites

- Flutter SDK ≥ 2.12.0
- Android Studio or VS Code with Flutter extensions
- Android SDK ≥ 21 (Android 5.0)
- Google Maps API key
- Physical Android device or emulator

## 🚀 Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/your-org/lightning-ride-mobile.git
cd lightning-ride-mobile
```

2. **Set up environment variables**
   Create a `.env` file in the project root:
```env
GOOGLE_MAPS_API_KEY=your_api_key_here
BACKEND_URL=https://your-backend-url
```

3. **Install dependencies**
```bash
flutter pub get
```

4. **Configure Android settings**
   Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="your_maps_api_key_here"/>
```

5. **Run the app**
```bash
flutter run
```

## 📦 Building for Release

1. **Generate release key**
```bash
keytool -genkey -v -keystore ~/key.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias upload
```

2. **Configure signing**
   Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-key.jks>
```

3. **Build APK**
```bash
flutter build apk --release
```

4. **Build App Bundle**
```bash
flutter build appbundle
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Supported Platforms

- Android 5.0 (API 21) and above
- iOS support coming soon

## 🔧 Configuration

Key configuration files:
- `lib/config/app_config.dart` - App settings
- `lib/config/theme.dart` - UI theme
- `lib/config/routes.dart` - Navigation routes

## 🛡️ Security Features

- Secure key storage using Android Keystore
- Certificate pinning for API calls
- Encrypted preferences storage
- Runtime integrity checks
- SafetyNet attestation

## 🔄 State Management

The app uses Provider for state management:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => LocationService()),
    Provider(create: (_) => PhoenixSocket()),
  ],
  child: LightningRideApp(),
)
```

## 📁 Project Structure

```
lib/
├── config/           # App configuration
├── models/           # Data models
├── screens/          # UI screens
├── services/         # Business logic
├── widgets/          # Reusable components
├── utils/            # Helper functions
└── main.dart         # App entry point
```

## 🔌 API Integration

- WebSocket connection for real-time updates
- REST API for standard operations
- Lightning Network node communication
- Google Maps Platform integration

## 📊 Analytics & Monitoring

- Crash reporting via Firebase Crashlytics
- Performance monitoring
- User analytics
- Network logging

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Development Guidelines

- Follow Flutter best practices
- Use meaningful variable names
- Write unit tests for new features
- Update documentation
- Format code with `flutter format`
- Run `flutter analyze` before committing

## 🐛 Known Issues

- [#123](https://github.com/your-org/lightning-ride-mobile/issues/123) - Background location updates on some Android 12 devices
- [#124](https://github.com/your-org/lightning-ride-mobile/issues/124) - Wallet connection timeout in poor network conditions

## 📱 Screenshots

<table>
  <tr>
    <td><img src="screenshots/login.png" width="200"/></td>
    <td><img src="screenshots/map.png" width="200"/></td>
    <td><img src="screenshots/ride.png" width="200"/></td>
    <td><img src="screenshots/payment.png" width="200"/></td>
  </tr>
</table>

## 🔜 Roadmap

- [ ] iOS support
- [ ] Multiple language support
- [ ] Offline maps
- [ ] Advanced payment features
- [ ] Driver earnings dashboard

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team
- Lightning Network developers
- Nostr protocol contributors
- Google Maps Platform team

## 📞 Support

For support:
- Join our [Discord](https://discord.gg/lightningride)
- Email: mobile-support@lightningride.com
- Submit issues on GitHub