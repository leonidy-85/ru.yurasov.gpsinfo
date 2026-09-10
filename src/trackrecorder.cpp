#include "trackrecorder.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QXmlStreamWriter>

TrackRecorder::TrackRecorder(QObject *parent) :
    QObject(parent),
    m_recording(false)
{
}

void TrackRecorder::start()
{
    this->m_points.clear();
    emit this->pointCountChanged(this->m_points.size());
    this->m_recording = true;
    emit this->recordingChanged(true);
}

void TrackRecorder::stop()
{
    this->m_recording = false;
    emit this->recordingChanged(false);
}

void TrackRecorder::clear()
{
    this->m_points.clear();
    emit this->pointCountChanged(0);
}

void TrackRecorder::addPosition(double latitude, double longitude, double altitude, const QDateTime &timestamp)
{
    if (!this->m_recording)
        return;
    TrackPoint point;
    point.coordinate = QGeoCoordinate(latitude, longitude, altitude);
    point.timestamp = timestamp;
    this->m_points.append(point);
    emit this->pointCountChanged(this->m_points.size());
}

QString TrackRecorder::save()
{
    if (this->m_points.isEmpty())
        return QString();

    const QString baseDir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + "/ru.yurasov.gpsinfo/tracks";
    QDir dir(baseDir);
    if (!dir.exists() && !QDir().mkpath(baseDir))
        return QString();

    const QString stamp = this->m_points.first().timestamp.isValid()
            ? this->m_points.first().timestamp.toString("yyyyMMdd-hhmmss")
            : QDateTime::currentDateTime().toString("yyyyMMdd-hhmmss");
    const QString fileName = baseDir + "/track-" + stamp + ".gpx";

    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return QString();

    QXmlStreamWriter xml(&file);
    xml.setAutoFormatting(true);
    xml.writeStartDocument();
    xml.writeStartElement("gpx");
    xml.writeAttribute("version", "1.1");
    xml.writeAttribute("creator", "GPSInfo");
    xml.writeAttribute("xmlns", "http://www.topografix.com/GPX/1/1");
    xml.writeStartElement("trk");
    xml.writeTextElement("name", "GPSInfo " + stamp);
    xml.writeStartElement("trkseg");
    foreach (const TrackPoint &point, this->m_points) {
        xml.writeStartElement("trkpt");
        xml.writeAttribute("lat", QString::number(point.coordinate.latitude(), 'f', 6));
        xml.writeAttribute("lon", QString::number(point.coordinate.longitude(), 'f', 6));
        if (point.coordinate.altitude() != 0.0)
            xml.writeTextElement("ele", QString::number(point.coordinate.altitude(), 'f', 1));
        if (point.timestamp.isValid())
            xml.writeTextElement("time", point.timestamp.toUTC().toString(Qt::ISODate));
        xml.writeEndElement();
    }
    xml.writeEndElement();
    xml.writeEndElement();
    xml.writeEndElement();
    xml.writeEndDocument();
    file.close();

    emit this->saved(fileName);
    return fileName;
}
