# ApibayMagnet — iOS app

A native SwiftUI app that searches [apibay](https://apibay.org) and copies magnet
links. Because native `URLSession` isn't subject to browser CORS, the app calls
apibay directly from your device — **no proxy/Worker needed**.

- **Target:** iOS 17+
- **Dependencies:** none (SwiftUI + Foundation only)

## Source files (`ApibayMagnet/`)

| File | Responsibility |
|------|----------------|
| `ApibayMagnetApp.swift` | App entry point |
| `Torrent.swift` | Result model + magnet/size/date/extension helpers |
| `Trackers.swift` | Tracker list + magnet builder (+ `encodeURIComponent` equivalent) |
| `SortOption.swift` | Sort options and comparators (default: seeders, most first) |
| `ApibayClient.swift` | `URLSession` call to `apibay.org/q.php` |
| `SearchViewModel.swift` | Search state + in-memory sorting |
| `ContentView.swift` | Search UI, sort menu, list, tap-to-copy, share, pull-to-refresh |
| `TorrentRow.swift` | One result row |

## Build it in Xcode

1. **File ▸ New ▸ Project… ▸ iOS ▸ App.**
   - Product Name: `ApibayMagnet`
   - Interface: **SwiftUI**, Language: **Swift**
   - Bundle Identifier: e.g. `com.kristjanr.apibaymagnet`
2. In the new project, delete the auto-generated `ContentView.swift` and
   `ApibayMagnetApp.swift`, then **drag all 8 files from `ApibayMagnet/` into the
   project** (check "Copy items if needed" and add to the app target).
3. Select the project ▸ target ▸ **General** ▸ set **Minimum Deployments = iOS 17.0**.
4. **Signing & Capabilities** ▸ check **Automatically manage signing** ▸ pick your
   personal Apple ID **Team** (free account is fine).
5. Pick a Simulator (e.g. iPhone 15) and press **Run** (⌘R) to try it, or plug in
   your iPhone, select it, and Run to install directly.

## Persistent install via AltStore / SideStore (no weekly rebuilds)

A free Apple ID signs apps for only 7 days. AltStore/SideStore re-signs and
**auto-refreshes** in the background so it keeps working.

1. In Xcode select **Any iOS Device (arm64)** as the run destination.
2. **Product ▸ Archive.**
3. In the Organizer, right-click the archive ▸ **Show in Finder** ▸ right-click the
   `.xcarchive` ▸ **Show Package Contents** ▸ `Products/Applications/`.
4. Make a new folder named **`Payload`**, copy **`ApibayMagnet.app`** into it,
   then compress `Payload` and rename the resulting zip to **`ApibayMagnet.ipa`**.
5. Install that `.ipa` with **AltStore** (or **SideStore**). It re-signs with your
   Apple ID and refreshes automatically.

## Verify

- Search `rick morty` → results appear, default sorted by seeders (most first).
- Change the sort menu → list reorders instantly (no new request).
- Tap a row → "Magnet copied"; paste elsewhere to confirm it starts with
  `magnet:?xt=urn:btih:` and includes `&tr=` trackers.
- Swipe a row ▸ Share → the share sheet offers the magnet URL.
- Search gibberish (e.g. `zxqwvasdf1234`) → "No Results" state, no crash.
- Airplane Mode → search → error state with **Retry**; recovers when back online.
- Pull down the list → re-runs the current query.
