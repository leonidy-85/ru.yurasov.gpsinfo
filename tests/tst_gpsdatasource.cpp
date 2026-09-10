#include <QtTest>
#include <QSignalSpy>
#include <QDateTime>
#include <QFile>
#include <QGeoSatelliteInfo>
#include <QStandardPaths>
#include "gpsdatasource.h"
#include "gpsinfosettings.h"
#include "trackrecorder.h"

static QGeoSatelliteInfo makeSatellite(int identifier,
                                       QGeoSatelliteInfo::SatelliteSystem system,
                                       qreal azimuth,
                                       qreal elevation,
                                       int signalStrength)
{
    QGeoSatelliteInfo info;
    info.setSatelliteIdentifier(identifier);
    info.setSatelliteSystem(system);
    info.setAttribute(QGeoSatelliteInfo::Azimuth, azimuth);
    info.setAttribute(QGeoSatelliteInfo::Elevation, elevation);
    info.setSignalStrength(signalStrength);
    return info;
}

static GPSSatellite* satelliteAt(const GPSSatelliteModel &model, int row)
{
    return model.data(model.index(row, 0), Qt::DisplayRole).value<GPSSatellite*>();
}

class tst_GpsSatelliteModel : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void initialState();
    void reconcileAddsSatellites();
    void reconcileUpdatesInPlace();
    void reconcileRemovesMissing();
    void reconcileRespectsShowAll();
    void reconcileDoesNotEmitWhenUnchanged();
    void markInUse();
    void clearModel();
    void roleNames();
    void settingsReset();
    void trackRecorderStartStop();
    void trackRecorderSave();
};

void tst_GpsSatelliteModel::initTestCase()
{
    QStandardPaths::setTestModeEnabled(true);
}

void tst_GpsSatelliteModel::initialState()
{
    GPSSatelliteModel model;
    QCOMPARE(model.rowCount(), 0);
}

void tst_GpsSatelliteModel::reconcileAddsSatellites()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30)
          << makeSatellite(2, QGeoSatelliteInfo::GLONASS, 40.0, 50.0, 25);

    model.reconcile(infos, true);

    QCOMPARE(model.rowCount(), 2);
    GPSSatellite *first = satelliteAt(model, 0);
    QVERIFY(first);
    QCOMPARE(first->getIdentifier(), 1);
    QCOMPARE(first->getAzimuth(), 10.0);
    QCOMPARE(first->getElevation(), 20.0);
    QCOMPARE(first->getSignalStrength(), 30);
    QCOMPARE(first->isInUse(), false);
    QCOMPARE(satelliteAt(model, 1)->getIdentifier(), 2);
}

void tst_GpsSatelliteModel::reconcileUpdatesInPlace()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30);
    model.reconcile(infos, true);
    GPSSatellite *before = satelliteAt(model, 0);

    QSignalSpy spy(&model, &QAbstractItemModel::dataChanged);
    infos[0] = makeSatellite(1, QGeoSatelliteInfo::GPS, 11.0, 21.0, 35);
    model.reconcile(infos, true);

    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(spy.count(), 1);
    GPSSatellite *after = satelliteAt(model, 0);
    QCOMPARE(after, before);
    QCOMPARE(after->getSignalStrength(), 35);
}

void tst_GpsSatelliteModel::reconcileRemovesMissing()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30)
          << makeSatellite(2, QGeoSatelliteInfo::GLONASS, 40.0, 50.0, 25);
    model.reconcile(infos, true);
    QCOMPARE(model.rowCount(), 2);

    QList<QGeoSatelliteInfo> remaining;
    remaining << infos[0];
    model.reconcile(remaining, true);

    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(satelliteAt(model, 0)->getIdentifier(), 1);
}

void tst_GpsSatelliteModel::reconcileRespectsShowAll()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30)
          << makeSatellite(2, QGeoSatelliteInfo::GPS, 40.0, 50.0, 0);

    model.reconcile(infos, false);
    QCOMPARE(model.rowCount(), 1);

    model.reconcile(infos, true);
    QCOMPARE(model.rowCount(), 2);
}

void tst_GpsSatelliteModel::reconcileDoesNotEmitWhenUnchanged()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30);
    model.reconcile(infos, true);

    QSignalSpy spy(&model, &QAbstractItemModel::dataChanged);
    model.reconcile(infos, true);

    QCOMPARE(spy.count(), 0);
}

void tst_GpsSatelliteModel::markInUse()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30)
          << makeSatellite(2, QGeoSatelliteInfo::GLONASS, 40.0, 50.0, 25);
    model.reconcile(infos, true);

    QList<QGeoSatelliteInfo> used;
    used << infos[1];
    model.markInUse(used);

    QCOMPARE(satelliteAt(model, 0)->isInUse(), false);
    QCOMPARE(satelliteAt(model, 1)->isInUse(), true);

    model.markInUse(QList<QGeoSatelliteInfo>());
    QCOMPARE(satelliteAt(model, 1)->isInUse(), false);
}

void tst_GpsSatelliteModel::clearModel()
{
    GPSSatelliteModel model;
    QList<QGeoSatelliteInfo> infos;
    infos << makeSatellite(1, QGeoSatelliteInfo::GPS, 10.0, 20.0, 30);
    model.reconcile(infos, true);

    model.clear();

    QCOMPARE(model.rowCount(), 0);
}

void tst_GpsSatelliteModel::roleNames()
{
    GPSSatelliteModel model;
    QHash<int, QByteArray> roles = model.roleNames();
    QCOMPARE(roles.value(Qt::DisplayRole), QByteArray("modelData"));
    QCOMPARE(roles.value(GPSSatelliteModel::SatelliteRole), QByteArray("satellite"));
}

void tst_GpsSatelliteModel::settingsReset()
{
    GPSInfoSettings settings;
    settings.setShowAltitudeApp(false);
    settings.setCoordinateFormat("DEC");
    QCOMPARE(settings.getShowAltitudeApp(), false);

    settings.resetToDefaults();

    QCOMPARE(settings.getShowAltitudeApp(), true);
    QCOMPARE(settings.getCoordinateFormat(), QString("DEG"));
}

void tst_GpsSatelliteModel::trackRecorderStartStop()
{
    TrackRecorder recorder;
    QCOMPARE(recorder.isRecording(), false);
    QCOMPARE(recorder.pointCount(), 0);

    recorder.addPosition(55.75, 37.61, 150.0, QDateTime::currentDateTime());
    QCOMPARE(recorder.pointCount(), 0);

    recorder.start();
    QCOMPARE(recorder.isRecording(), true);
    recorder.addPosition(55.75, 37.61, 150.0, QDateTime::currentDateTime());
    recorder.addPosition(55.76, 37.62, 155.0, QDateTime::currentDateTime());
    QCOMPARE(recorder.pointCount(), 2);

    recorder.stop();
    QCOMPARE(recorder.isRecording(), false);

    recorder.clear();
    QCOMPARE(recorder.pointCount(), 0);
}

void tst_GpsSatelliteModel::trackRecorderSave()
{
    TrackRecorder recorder;
    recorder.start();
    recorder.addPosition(55.75, 37.61, 150.0, QDateTime::currentDateTime());
    recorder.addPosition(55.76, 37.62, 155.0, QDateTime::currentDateTime());

    const QString path = recorder.save();
    QVERIFY(!path.isEmpty());
    QVERIFY(QFile::exists(path));

    QFile file(path);
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    const QByteArray content = file.readAll();
    file.close();
    QVERIFY(content.contains("<gpx"));
    QVERIFY(content.contains("trkpt"));

    QFile::remove(path);
}

QTEST_MAIN(tst_GpsSatelliteModel)
#include "tst_gpsdatasource.moc"
