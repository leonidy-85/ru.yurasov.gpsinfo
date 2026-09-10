TARGET = ru.yurasov.gpsinfo

CONFIG += auroraapp
CONFIG += auroraapp_i18n

SOURCES += \
    src/gpsdatasource.cpp \
    src/qmlsettingswrapper.cpp \
    src/gpsinfosettings.cpp \
    src/gpsinfo.cpp

DISTFILES += \
    qml/gpsinfo.qml \
    qml/components/AboutLabel.qml \
    qml/components/AppBarMenu.qml \
    qml/components/DoubleSwitch.qml \
    qml/components/InfoField.qml \
    qml/components/LocationFormatter.qml \
    qml/components/Providers.qml \
    qml/pages/AboutPage.qml \
    qml/pages/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/LicensePage.qml \
    qml/pages/SatelliteBarchartPage.qml \
    qml/pages/SatelliteInfoPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/TabMainPage.qml \
    qml/tabview/TabBar.qml \
    qml/tabview/TabButton.qml \
    qml/tabview/TabItem.qml \
    qml/tabview/TabView.qml \
    qml/tabview/Util.js \
    qml/QChart/QChart.js \
    qml/QChart/QChart.qml \
    qml/QChart/QChartGallery.js \
    qml/QChart/QChartGallery.qml \
    qml/QChart/qmldir \
    rpm/ru.yurasov.gpsinfo.changes \
    rpm/ru.yurasov.gpsinfo.spec \
    ru.yurasov.gpsinfo.desktop

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172
HEADERS += \
    src/gpsdatasource.h \
    src/qmlsettingswrapper.h \
    src/gpsinfosettings.h

QT += positioning

TRANSLATIONS = translations/ru.yurasov.gpsinfo-ru.ts

images.files = \
    images/coverbg.png

#images.path = /usr/share/ru.yurasov.gpsinfo/images
INSTALLS += images


VERSION = $$system( egrep "^Version:\|^Release:" rpm/ru.yurasov.gpsinfo.spec |tr -d "[A-Z][a-z]: " | tr "\\\n" "-" | sed "s/\.$//g"| tr -d "[:space:]")

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
