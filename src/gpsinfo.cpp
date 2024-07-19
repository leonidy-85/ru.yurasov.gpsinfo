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
    QStringList locales;
    QString baseName("/usr/share/ru.yurasov.gpsinfo/translations/");
    QDir localesDir(baseName);
    if (localesDir.exists()) {
        locales = localesDir.entryList(QStringList() << "*.qm", QDir::Files | QDir::NoDotAndDotDot, QDir::Name | QDir::IgnoreCase);
    }
    locales.replaceInStrings(".qm", "");
    QString currentLocale = settings->getLocale();
    qDebug() << "loading language" << currentLocale;
    QTranslator* translator = new QTranslator();
    QString fileName = currentLocale.compare("en") == 0 ? "gpsinfo.qm" : "gpsinfo_"+currentLocale+".qm";
    translator->load(fileName, baseName);
    QGuiApplication::installTranslator(translator);

    QQuickView *view = Application::createView();
    view->rootContext()->setContextProperty("settings", settings);
    view->setSource(Application::pathTo("qml/gpsinfo.qml"));
    view->showFullScreen();
    return qGuiAppl->exec();
}
