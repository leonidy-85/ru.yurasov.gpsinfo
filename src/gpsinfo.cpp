#include <QtQuick>

#include <auroraapp.h>
#include <QTranslator>
#include "gpsdatasource.h"
#include "gpsinfosettings.h"

using namespace Aurora;


int main(int argc, char *argv[]) {
    //migrate old configuration
    QDir configdir = QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation));
    if (configdir.cd("gpsinfo")) {
        configdir.rename("gpsinfo.conf", "ru.yurasov.gpsinfo.conf");
        configdir.cdUp();
        configdir.rename("gpsinfo", "ru.yurasov.gpsinfo");
    }

    qmlRegisterType<GPSDataSource>("Yurasov.GPSInfo", 1, 0, "GPSDataSource");
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
