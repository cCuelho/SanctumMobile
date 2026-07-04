# Sanctum Mobile

Flutter device bridge for **Sanctum Wellness OS** — reads **Apple Health** (iOS) and **Health Connect** (Android), then pushes normalized batches to the Sanctum ingest API.

**Server repo:** [cCuelho/Sanctum](https://github.com/cCuelho/Sanctum)  
**API contract:** [MOBILE_INGEST.md](https://github.com/cCuelho/Sanctum/blob/redesign/os/docs/MOBILE_INGEST.md)

This app is **not** deployed on the Sanctum VPS. It ships via App Store / Play Store (or TestFlight / sideload during dev).

---

## First-time setup

This repo contains **Dart source only**. Platform folders (`ios/`, `android/`) are generated on a machine with Flutter installed:

```bash
git clone https://github.com/cCuelho/SanctumMobile.git
cd SanctumMobile
flutter create --org net.sanctumwellness --project-name sanctum_mobile .
flutter pub get
```

Then configure health permissions — see [docs/SETUP.md](docs/SETUP.md).

---

## Run

**iOS (Mac + Xcode required):**

```bash
flutter run --dart-define=SANCTUM_API_BASE=http://YOUR_LAN_IP:5000
```

**Android (Windows or Mac):**

```bash
flutter run --dart-define=SANCTUM_API_BASE=http://YOUR_LAN_IP:5000 \
  --dart-define=SANCTUM_SOURCE_PROVIDER=health_connect
```

Production:

```bash
flutter run \
  --dart-define=SANCTUM_API_BASE=https://sanctum.sanctumwellness.net \
  --dart-define=SANCTUM_INGEST_TOKEN=your-token
```

---

## Architecture

```
HealthKit / Health Connect
        ↓
  HealthBridge (lib/health/)
        ↓
  IngestClient → POST /api/sync/ingest
        ↓
  Sanctum canonical_records → coach + insights
```

---

## Status

| Platform | Status |
|----------|--------|
| iOS HealthKit | Scaffold — permissions + read steps/sleep |
| Android Health Connect | Scaffold — same via `health` package |
| Fitbit direct OAuth | Deferred — use Apple Health path if Fitbit syncs to Health |

---

## License

Private — same operator as Sanctum Wellness OS.
