# CalmAlarm 🌿☀️
### Social & Ambient Wake Application (F-Droid Compliant & 100% FOSS)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![F-Droid Ready](https://img.shields.io/badge/F--Droid-Compliant-brightgreen.svg)](.fdroid.yml)
[![Framework](https://img.shields.io/badge/Framework-Flutter%203.41-02569B.svg)](https://flutter.dev)

**CalmAlarm** reimagines morning wake-ups by swapping loud, panic-inducing audio alarms for **gentle circadian sunrise screen transitions**, **organic watercolor botanical characters**, and **playful co-op garden pods** for accountability across time zones.

---

## 🌟 Key Features

- **Circadian Sunrise Wake System**: Screen gradually warms from dark amber dawn to golden daylight over 5–30 minutes with subtle haptic pulses.
- **Organic Watercolor Botanical Engine**: Custom Flutter canvas rendering of sleepy buds blooming into vibrant watercolor flowers (*Zen Lotus, Wabi-Sabi Bonsai, Moss Bud*).
- **The Garden of Accountability (Sync Pods)**: Shared wake windows nourish a group garden plot. Snoozing or missing a window triggers playful embers or weeds on a friend's plot.
- **Co-op Rescue Pings**: One-tap *"Watering Can Nudge"* douses embers and gently wakes up pod members.
- **Dedicated OLED Nightstand Dock Mode**: Ultra-dark midnight display with ambient clock and soft breathing bud.
- **Cross-Timezone Moon & Sun Bridge**: Asynchronous and real-time presence tracking for LDR couples, remote teams, and study partners.

---

## 🛡️ F-Droid & Open-Source Compliance

CalmAlarm is built from day 1 for 100% Free and Open Source Software (FOSS) distribution on **F-Droid**:

1. **Zero Proprietary SDKs**: No Google Play Services binaries, Firebase Cloud Messaging (FCM) proprietary SDKs, or Google Analytics tracking.
2. **UnifiedPush & WebSockets**: Open push messaging using `UnifiedPush` (ntfy.sh / Gotify) and open-source **Supabase Realtime WebSockets**.
3. **Open Fonts & Licenses**: Uses SIL Open Font Licensed typography (*Outfit*, *Inter*, *Playfair Display*) and GPL-3.0 licensing.

---

## 🛠️ Tech Stack

- **Client**: Flutter 3.41+ (Dart 3.11+)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Rendering Engine**: Flutter `CustomPainter` vector watercolor engine
- **Backend & Sync**: Supabase Realtime (Open-Source PostgreSQL + GoTrue Auth)
- **Local Alarms**: Android `AlarmManager` / iOS `AlarmKit`

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.30.0 or higher)
- Android Studio / Xcode (for native simulator running)

### Running locally
```bash
# Clone the repository
git clone https://github.com/calmalarm/calmalarm.git
cd calmalarm

# Fetch dependencies
flutter pub get

# Run on connected device or simulator
flutter run
```

### Running unit and widget tests
```bash
flutter test
```

---

## 📄 License
This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
