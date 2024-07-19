TARGET = ru.yurasov.gpsinfo

CONFIG += auroraapp
CONFIG += auroraapp_i18n

SOURCES += \
    src/gpsdatasource.cpp \
    src/qmlsettingswrapper.cpp \
    src/gpsinfosettings.cpp \
    src/gpsinfo.cpp

DISTFILES += \
    qml/components/AppBarMenu.qml \
    qml/gpsinfo.qml \
    qml/pages/SatelliteInfoPage.qml \
    qml/pages/CoverPage.qml \
    qml/pages/TabMainPage.qml \
    qml/pages/TabMainPage.qml \
    qml/components/AboutLabel.qml \
    qml/tabview/Util.js \
    qml/tabview/TabView.qml \
    qml/tabview/TabItem.qml \
    qml/tabview/TabButton.qml \
    qml/tabview/TabBar.qml \
    qml/QChart/QChart.js \
    qml/QChart/QChart.qml \
    qml/QChart/qmldir \
    qml/components/AppBarMenu.qml \
    qml/pages/FirstPage.qml \
    qml/components/InfoField.qml \
    qml/pages/SatelliteBarchartPage.qml \
    qml/pages/SettingsPage.qml \
    qml/LocationFormatter.qml \
    qml/components/Providers.qml \
    qml/components/DoubleSwitch.qml \
    qml/pages/AboutPage.qml \
    qml/pages/LicensePage.qml \
    rpm/ru.yurasov.gpsinfo.changes \
    rpm/ru.yurasov.gpsinfo.spec \
    rpm/ru.yurasov.gpsinfo.yaml \
    ru.yurasov.gpsinfo.desktop

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

HEADERS += \
    src/gpsdatasource.h \
    src/qmlsettingswrapper.h \
    src/gpsinfosettings.h

QT += positioning

TRANSLATIONS += \
    translations/gpsinfo_de.ts \
    translations/gpsinfo_es.ts \
    translations/gpsinfo_fi.ts \
    translations/gpsinfo_fr.ts \
    translations/gpsinfo_hu.ts \
    translations/gpsinfo_nl.ts \
    translations/gpsinfo_pl.ts \
    translations/gpsinfo_ru.ts \
    translations/gpsinfo_sk.ts \
    translations/gpsinfo_sv.ts \
    translations/gpsinfo_zh_CN.ts

images.files = \
    images/coverbg.png

#images.path = /usr/share/ru.yurasov.gpsinfo/images

INSTALLS += images
