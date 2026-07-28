# TrackIt 🎯

Standard to-do lists are built for convenience. TrackIt is built for discipline. 

TrackIt is a strict, offline-first accountability engine built with Flutter. It goes beyond simple checkboxes by demanding cryptographic-style photographic proof of work and aggressively managing your pending deadlines. 

Whether you are committing to daily deep work sessions, mastering a new skill, launching a startup, or locking in a strict morning routine, TrackIt ensures you don't just plan your day—you actually execute it.

## 🚀 The Core Engine

*   📸 **Photographic Proof of Work:** You cannot fake progress here. TrackIt requires native camera verification to mark any task as complete, forcing absolute accountability.
*   🥷 **Smart Deadline "Assassination":** The app automatically arms a targeted push notification exactly one hour before a task's deadline. If you put in the work and submit your photo early, the system silently neutralizes the alarm before it ever rings. 
*   📊 **Granular Analytics:** Visualize your momentum. A dedicated dashboard tracks your consistency, calculating real-time category completion percentages and logging microsecond-accurate timestamps for every finished objective.
*   🌅 **The 5:00 AM Reset:** Built for human reality, not computer logic. The background engine automatically refreshes daily recurring tasks at 5:00 AM rather than midnight, perfectly aligning with natural waking cycles.

## 🛠️ Technical Architecture

*   **Framework:** Flutter (Dart) for high-performance cross-platform rendering.
*   **Database:** SQLite for lightning-fast, secure, offline-first data persistence.
*   **Hardware Integration:** Direct utilization of native iOS/Android camera APIs and secure local file directories for image storage.
*   **Background Services:** Complex timezone-aware local push notification scheduling and lifecycle state management.

## ⚙️ Quick Start

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.0.0 or higher recommended)
*   An Android/iOS Emulator, or a physical device connected via USB/Wi-Fi debugging.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/TrackIt.git
   cd TrackIt
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
   *(Note: Ensure you grant the necessary camera and notification permissions upon the first launch!)*

## 📦 Live Release

Looking for the production-ready app? You can download the latest compiled Android APK directly from the Releases Tab.

*Designed and engineered to turn intentions into undeniable proof.*
