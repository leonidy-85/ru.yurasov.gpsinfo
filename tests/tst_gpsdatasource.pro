QT += testlib positioning
QT -= gui

CONFIG += c++11 console testcase
TEMPLATE = app
TARGET = tst_gpsdatasource

INCLUDEPATH += ../src

SOURCES += \
    tst_gpsdatasource.cpp \
    ../src/gpsdatasource.cpp \
    ../src/gpsinfosettings.cpp \
    ../src/qmlsettingswrapper.cpp

HEADERS += \
    ../src/gpsdatasource.h \
    ../src/gpsinfosettings.h \
    ../src/qmlsettingswrapper.h
