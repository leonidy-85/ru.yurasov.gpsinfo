#include "gpsdatasource.h"
#include <QDebug>

GPSSatellite::GPSSatellite(QObject *parent) :
    QObject(parent),
    azimuth(0),
    elevation(0),
    identifier(0),
    system(0),
    inUse(false),
    signalStrength(0) {
}

GPSSatelliteModel::GPSSatelliteModel(QObject *parent) :
    QAbstractListModel(parent) {
}

int GPSSatelliteModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) {
        return 0;
    }
    return this->satellites.size();
}

QVariant GPSSatelliteModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= this->satellites.size()) {
        return QVariant();
    }
    if (role == Qt::DisplayRole || role == SatelliteRole) {
        return QVariant::fromValue(this->satellites.at(index.row()));
    }
    return QVariant();
}

QHash<int, QByteArray> GPSSatelliteModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "modelData";
    roles[SatelliteRole] = "satellite";
    return roles;
}

int GPSSatelliteModel::indexOf(int identifier) const {
    for (int row = 0; row < this->satellites.size(); ++row) {
        if (this->satellites.at(row)->getIdentifier() == identifier) {
            return row;
        }
    }
    return -1;
}

void GPSSatelliteModel::reconcile(const QList<QGeoSatelliteInfo> &infos, bool showAll) {
    QList<QGeoSatelliteInfo> desired;
    for (auto info = infos.cbegin(); info < infos.cend(); info++) {
        if (showAll || info->signalStrength() > 0) {
            desired.append(*info);
        }
    }

    // Drop satellites that are no longer in view.
    for (int row = this->satellites.size() - 1; row >= 0; --row) {
        int identifier = this->satellites.at(row)->getIdentifier();
        bool found = false;
        for (auto info = desired.cbegin(); info < desired.cend(); info++) {
            if (info->satelliteIdentifier() == identifier) {
                found = true;
                break;
            }
        }
        if (!found) {
            beginRemoveRows(QModelIndex(), row, row);
            GPSSatellite* sat = this->satellites.takeAt(row);
            endRemoveRows();
            sat->deleteLater();
        }
    }

    // Add new satellites and update the existing ones in place.
    for (auto info = desired.cbegin(); info < desired.cend(); info++) {
        int row = this->indexOf(info->satelliteIdentifier());
        if (row < 0) {
            GPSSatellite* sat = new GPSSatellite(this);
            sat->setIdentifier(info->satelliteIdentifier());
            sat->setSystem(info->satelliteSystem());
            sat->setAzimuth(info->attribute(QGeoSatelliteInfo::Azimuth));
            sat->setElevation(info->attribute(QGeoSatelliteInfo::Elevation));
            sat->setSignalStrength(info->signalStrength());
            sat->setInUse(false);
            beginInsertRows(QModelIndex(), this->satellites.size(), this->satellites.size());
            this->satellites.append(sat);
            endInsertRows();
        } else {
            GPSSatellite* sat = this->satellites.at(row);
            bool changed = false;
            if (sat->getSystem() != info->satelliteSystem()) {
                sat->setSystem(info->satelliteSystem());
                changed = true;
            }
            qreal azimuth = info->attribute(QGeoSatelliteInfo::Azimuth);
            if (sat->getAzimuth() != azimuth) {
                sat->setAzimuth(azimuth);
                changed = true;
            }
            qreal elevation = info->attribute(QGeoSatelliteInfo::Elevation);
            if (sat->getElevation() != elevation) {
                sat->setElevation(elevation);
                changed = true;
            }
            if (sat->getSignalStrength() != info->signalStrength()) {
                sat->setSignalStrength(info->signalStrength());
                changed = true;
            }
            if (changed) {
                emit dataChanged(index(row), index(row));
            }
        }
    }
}

void GPSSatelliteModel::markInUse(const QList<QGeoSatelliteInfo> &infos) {
    QSet<int> inUse;
    for (auto info = infos.cbegin(); info < infos.cend(); info++) {
        inUse.insert(info->satelliteIdentifier());
    }

    for (int row = 0; row < this->satellites.size(); ++row) {
        GPSSatellite* sat = this->satellites.at(row);
        bool used = inUse.contains(sat->getIdentifier());
        if (sat->isInUse() != used) {
            sat->setInUse(used);
            emit dataChanged(index(row), index(row));
        }
    }

    // In-use satellites missing from the view report are still added.
    for (auto info = infos.cbegin(); info < infos.cend(); info++) {
        if (this->indexOf(info->satelliteIdentifier()) < 0) {
            GPSSatellite* sat = new GPSSatellite(this);
            sat->setIdentifier(info->satelliteIdentifier());
            sat->setSystem(info->satelliteSystem());
            sat->setAzimuth(info->attribute(QGeoSatelliteInfo::Azimuth));
            sat->setElevation(info->attribute(QGeoSatelliteInfo::Elevation));
            sat->setSignalStrength(info->signalStrength());
            sat->setInUse(true);
            beginInsertRows(QModelIndex(), this->satellites.size(), this->satellites.size());
            this->satellites.append(sat);
            endInsertRows();
        }
    }
}

void GPSSatelliteModel::clear() {
    if (this->satellites.isEmpty()) {
        return;
    }
    beginResetModel();
    QList<GPSSatellite*> old = this->satellites;
    this->satellites.clear();
    endResetModel();
    foreach (GPSSatellite* sat, old) {
        sat->deleteLater();
    }
}

GPSDataSource::GPSDataSource(QObject *parent) :
    QObject(parent), SimulatorTimer(this),
    satelliteModel(new GPSSatelliteModel(this)),
    numberOfUsedSatellites(0),
    numberOfVisibleSatellites(0)
{
    connect(&SimulatorTimer, SIGNAL(timeout()), this, SLOT(SimulatorTimeout()));

    this->sSource = QGeoSatelliteInfoSource::createDefaultSource(this);
    if (this->sSource) {
        qDebug() << "created QGeoSatelliteInfoSource" << this->sSource->sourceName();
        connect(this->sSource, SIGNAL(satellitesInUseUpdated(QList<QGeoSatelliteInfo>)), this, SLOT(satellitesInUseUpdated(QList<QGeoSatelliteInfo>)));
        connect(this->sSource, SIGNAL(satellitesInViewUpdated(QList<QGeoSatelliteInfo>)), this, SLOT(satellitesInViewUpdated(QList<QGeoSatelliteInfo>)));
    } else {
        qDebug() << "cannot create default QGeoSatelliteInfoSource";
    }
    this->active = false;
}

void GPSDataSource::satellitesInUseUpdated(const QList<QGeoSatelliteInfo> &infos) {
    this->satelliteModel->markInUse(infos);
    emit this->satellitesChanged();
    this->setNumberOfUsedSatellites(infos.size());
}

void GPSDataSource::satellitesInViewUpdated(const QList<QGeoSatelliteInfo> &infos) {
    this->satelliteModel->reconcile(infos, this->settings.getShowEmptyChannels());
    emit this->satellitesChanged();
    this->setNumberOfVisibleSatellites(this->satelliteModel->rowCount());
}

QVariantList GPSDataSource::getSatellites() {
    QVariantList result;
    foreach (GPSSatellite* sat, this->satelliteModel->getSatellites()) {
        result << QVariant::fromValue(sat);
    }
    return result;
}

void GPSDataSource::setActive(bool active) {
    if ( !sSource )
    {
        if ( !this->active && active )
        {
            SimulatorTimer.start(1000);
            this->active = true;
        }
        else if ( this->active && !active )
        {
            SimulatorTimer.stop();
            this->active = false;
        }
        return;
    }
    if (!this->active && active) {
        qDebug() << "activating source...";
        this->sSource->startUpdates();
        this->active = true;
        emit this->activeChanged(true);
    } else if (this->active && !active) {
        qDebug() << "deactivating source...";
        this->sSource->stopUpdates();
        this->active = false;
        this->satelliteModel->clear();
        emit this->activeChanged(false);
        emit this->satellitesChanged();
    }
}

void GPSDataSource::setUpdateIntervalMs(int updateInterval) {
    if (this->sSource) {
        this->sSource->setUpdateInterval(updateInterval);
    }
    emit this->updateIntervalMsChanged(updateInterval);
}

void GPSDataSource::SimulatorTimeout()
{
    QList<QGeoSatelliteInfo> satellites, satellitesInUse;
    QGeoSatelliteInfo satellite;

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 60.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 45.0);
    satellite.setSatelliteIdentifier(8);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(40);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 100.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 40.0);
    satellite.setSatelliteIdentifier(22);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GLONASS);
    satellite.setSignalStrength(35);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 200.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 60.0);
    satellite.setSatelliteIdentifier(131);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(30);
    satellites.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 80.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 45.0);
    satellite.setSatelliteIdentifier(9);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(22);
    satellites.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 120.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 40.0);
    satellite.setSatelliteIdentifier(21);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GLONASS);
    satellite.setSignalStrength(16);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 250.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 60.0);
    satellite.setSatelliteIdentifier(228);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(3);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 280.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 75.0);
    satellite.setSatelliteIdentifier(247);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(0);
    satellites.append(satellite);

    satellitesInViewUpdated(satellites);
    satellitesInUseUpdated(satellitesInUse);
}
