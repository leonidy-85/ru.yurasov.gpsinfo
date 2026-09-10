#ifndef TRACKRECORDER_H
#define TRACKRECORDER_H

#include <QObject>
#include <QDateTime>
#include <QGeoCoordinate>
#include <QList>
#include <QString>

class TrackRecorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool recording READ isRecording NOTIFY recordingChanged)
    Q_PROPERTY(int pointCount READ pointCount NOTIFY pointCountChanged)
public:
    explicit TrackRecorder(QObject *parent = 0);

    bool isRecording() const { return this->m_recording; }
    int pointCount() const { return this->m_points.size(); }

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QString save();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void addPosition(double latitude, double longitude, double altitude, const QDateTime &timestamp);

signals:
    void recordingChanged(bool);
    void pointCountChanged(int);
    void saved(const QString &path);

private:
    struct TrackPoint {
        QGeoCoordinate coordinate;
        QDateTime timestamp;
    };

    QList<TrackPoint> m_points;
    bool m_recording;
};

#endif // TRACKRECORDER_H
