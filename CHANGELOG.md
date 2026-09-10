# Changelog

## 0.15.3
- Add track recording with GPX export (start / stop / save in the app menu)
- Add time-series graphs tab: speed, altitude, horizontal accuracy, satellites in use and signal strength (max / avg)
- Add UTM coordinate format, automatic magnetic declination and a UTC time field
- Add "Share location" (Sailfish Share) and "Reset settings" actions
- Fix flickable bindings, configuration migration from harbour-gpsinfo and magnetic declination input range (−180..180)
- Rename `updateInterval` to `updateIntervalMs`, drop the unused cover image
- Add GitHub Actions CI that builds and runs the unit tests
- Fix the AppBar header fallback on the graphs page

## 0.15.2 (Aurora OS port)
- Port the app from Sailfish OS to Aurora OS and rename the package and configuration to `ru.yurasov.gpsinfo`
- Update satellites incrementally through a `QAbstractListModel` instead of deleting and recreating them on every update (fixes radar freezes)
- Fix the update interval being passed to Qt in seconds instead of milliseconds
- Fix loading of the installed translations and persistence of the selected language
- Use the QML position source for movement direction and drop the duplicate C++ source
- Human-readable tab titles, dead code cleanup, README and spec updates
- Add a Qt Test suite for the satellite model

For older releases see `rpm/ru.yurasov.gpsinfo.changes`.