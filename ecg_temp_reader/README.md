# ecg_temp_reader

Offline-capable ECG and temperature monitor with local user accounts and scan history.

## Usage

- On first launch, you will see the Login screen.
- Tap "Create account" to register a new user (username + password).
- After registration or login, you are taken to the Live Monitor screen that shows:
  - Real-time ECG chart from WebSocket.
  - Current temperature value.
- To capture a scan:
  - While on Live Monitor, tap the floating Scan button (save icon).
  - The app stores the current temperature and last 200 ECG samples locally for the logged-in user.
  - A "Saved" snackbar confirms the scan was stored.
- To view previous scans:
  - Open the drawer (top-left menu icon) and choose "My Results".
  - You will see a list of scans for the current user ordered by newest first.
  - Tap a scan to open details, including temperature and ECG chart drawn from stored samples.
  - Swipe a scan item to delete it.
- To logout:
  - Open the drawer and tap "Logout".
  - You will return to the Login screen. The last logged-in user is remembered between launches until logout.
