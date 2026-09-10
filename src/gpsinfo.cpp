#include <QtQuick>

#include <auroraapp.h>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QTranslator>
#include "gpsdatasource.h"
#include "gpsinfosettings.h"
#include "trackrecorder.h"

using namespace Aurora;


int main(int argc, char *argv[]) {
    // Migrate configuration from the old (harbour-gpsinfo / gpsinfo) locations.
    const QString configRoot = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    const QString newDirName = "ru.yurasov.gpsinfo";
    const QString newFileName = "ru.yurasov.gpsinfo.conf";
    const QStringList oldNames = QStringList() << "gpsinfo" << "harbour-gpsinfo";
    foreach (const QString &oldName, oldNames) {
        QDir oldDir(configRoot + "/" + oldName);
        if (!oldDir.exists())
            continue;
        QDir newDir(configRoot + "/" + newDirName);
        if (!newDir.exists())
            QDir(configRoot).mkpath(newDirName);
        const QString oldFile = oldName + ".conf";
        if (!QFile::exists(newDir.filePath(newFileName)) && QFile::exists(oldDir.filePath(oldFile)))
            QFile::copy(oldDir.filePath(oldFile), newDir.filePath(newFileName));
    }

    qmlRegisterType<GPSDataSource>("Yurasov.GPSInfo", 1, 0, "GPSDataSource");
    qmlRegisterType<TrackRecorder>("Yurasov.GPSInfo", 1, 0, "TrackRecorder");
    qmlRegisterType<GPSSatellite>();
    GPSInfoSettings* settings = new GPSInfoSettings();

    QGuiApplication* qGuiAppl = Application::application(argc, argv);
    QString baseName("/usr/share/ru.yurasov.gpsinfo/translations/");
    QString currentLocale = settings->getLocale();
    QString language = currentLocale.left(2);
    qDebug() << "loading language" << language;
    if (language.compare("en") != 0) {
        QTranslator* translator = new QTranslator();
        QString fileName = "ru.yurasov.gpsinfo-" + language + ".qm";
        if (translator->load(fileName, baseName)) {
            QGuiApplication::installTranslator(translator);
        } else {
            qDebug() << "cannot load translation" << fileName << "from" << baseName;
        }
    }

    QQuickView *view = Application::createView();
    view->rootContext()->setContextProperty("settings", settings);
    view->rootContext()->setContextProperty("version", APP_VERSION);
    view->setSource(Application::pathTo("qml/gpsinfo.qml"));
    view->showFullScreen();
    return qGuiAppl->exec();
}
