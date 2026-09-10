# GPSInfo

GPSInfo is a utility for Aurora OS to check the details of the GPS positioning system. It can tell you your location, speed, direction, the signal strength of the satellites and a lot more!

This project is a fork of [balta3/sailfish-gpsinfo](https://github.com/balta3/sailfish-gpsinfo), ported to Aurora OS and published under the package name `ru.yurasov.gpsinfo`.

# Compiling

To compile GPSInfo, clone the repo and initialize the submodule:

```bash
$ git clone git@github.com:leonidy-85/ru.yurasov.gpsinfo.git
$ cd ru.yurasov.gpsinfo
$ git submodule init
$ git submodule update
```

Open `ru.yurasov.gpsinfo.pro` in the Aurora SDK (Qt Creator), select a build target and hit run.

# Translations

Translations live in `translations/ru.yurasov.gpsinfo-<lang>.ts` and are compiled to `.qm` at build time by the `auroraapp_i18n` qmake feature. The active language can be changed in the settings; the app has to be restarted for the change to take effect.
