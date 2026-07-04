# Sanctum Mobile — platform setup

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+)
- **iOS:** Mac with Xcode, Apple Developer account for device testing
- **Android:** Android Studio, device or emulator with Health Connect installed
- Sanctum backend running with `POST /api/sync/ingest` (see Sanctum `docs/MOBILE_INGEST.md`)

---

## 1. Generate platform projects

From repo root (only needed once):

```bash
flutter create --org net.sanctumwellness --project-name sanctum_mobile .
flutter pub get
```

---

## 2. iOS — HealthKit

Edit `ios/Runner/Info.plist` — add inside `<dict>`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Sanctum reads steps and sleep from Apple Health to show trends in your private wellness journal.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Sanctum does not write to Apple Health.</string>
```

In Xcode → Runner target → **Signing & Capabilities** → **+ Capability** → **HealthKit** (read only).

Enable **HealthKit** background delivery later if you want periodic sync.

### Fitbit via Apple Health

If Fitbit syncs to Apple Health on iPhone, Sanctum Mobile reads it through HealthKit — no Fitbit OAuth needed.

---

## 3. Android — Health Connect

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_SLEEP"/>
```

Follow [health package Android setup](https://pub.dev/packages/health) for Health Connect availability checks.

Run with:

```bash
flutter run --dart-define=SANCTUM_SOURCE_PROVIDER=health_connect
```

---

## 4. Sanctum server

| Environment | API base |
|-------------|----------|
| Local LAN | `http://192.168.x.x:5000` |
| Production | `https://sanctum.sanctumwellness.net` |

Set ingest token on server (`MOBILE_INGEST_TOKEN`) and in the app (Settings field or `--dart-define=SANCTUM_INGEST_TOKEN=...`).

---

## 5. Verify end-to-end

1. Run Sanctum Flask locally or use VPS
2. Run Sanctum Mobile on device
3. Tap **Sync to Sanctum**
4. In browser: `/input/import?section=devices` → Apple Health or Health Connect shows **Last sync**
5. Ask coach about steps/sleep

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| 401 Unauthorized | Set matching `MOBILE_INGEST_TOKEN` on server and app |
| 0 records | Grant Health permissions; ensure Fitbit/data exists in Health app |
| Connection refused | Use LAN IP not `localhost` on physical device |
| iOS build fails | Open `ios/Runner.xcworkspace` in Xcode, fix signing |
