#include "gpsinfosettings.h"

GPSInfoSettings::GPSInfoSettings(QObject *parent) :
    QMLSettingsWrapper("ru.yurasov.gpsinfo", "ru.yurasov.gpsinfo", parent)
{
}

void GPSInfoSettings::resetToDefaults()
{
    this->clear();
    emit coordinateFormatChanged(getCoordinateFormat());
    emit localeChanged(getLocale());
    emit showAltitudeAppChanged(getShowAltitudeApp());
    emit showAltitudeCoverChanged(getShowAltitudeCover());
    emit showCompassDirectionAppChanged(getShowCompassDirectionApp());
    emit showCompassDirectionCoverChanged(getShowCompassDirectionCover());
    emit showCompassCalibrationAppChanged(getShowCompassCalibrationApp());
    emit showCompassCalibrationCoverChanged(getShowCompassCalibrationCover());
    emit showDirectionIndicatorChanged(getShowDirectionIndicator());
    emit showGpsStateAppChanged(getShowGpsStateApp());
    emit showGpsStateCoverChanged(getShowGpsStateCover());
    emit showHorizontalAccuracyAppChanged(getShowHorizontalAccuracyApp());
    emit showHorizontalAccuracyCoverChanged(getShowHorizontalAccuracyCover());
    emit showLastUpdateAppChanged(getShowLastUpdateApp());
    emit showLastUpdateCoverChanged(getShowLastUpdateCover());
    emit showLatitudeAppChanged(getShowLatitudeApp());
    emit showLatitudeCoverChanged(getShowLatitudeCover());
    emit showLongitudeAppChanged(getShowLongitudeApp());
    emit showLongitudeCoverChanged(getShowLongitudeCover());
    emit showMagneticNorthChanged(getShowMagneticNorth());
    emit showMovementDirectionAppChanged(getShowMovementDirectionApp());
    emit showMovementDirectionCoverChanged(getShowMovementDirectionCover());
    emit showSatelliteInfoAppChanged(getShowSatelliteInfoApp());
    emit showSatelliteInfoCoverChanged(getShowSatelliteInfoCover());
    emit showSpeedAppChanged(getShowSpeedApp());
    emit showSpeedCoverChanged(getShowSpeedCover());
    emit showVerticalAccuracyAppChanged(getShowVerticalAccuracyApp());
    emit showVerticalAccuracyCoverChanged(getShowVerticalAccuracyCover());
    emit speedUnitChanged(getSpeedUnit());
    emit unitsChanged(getUnits());
    emit barChartOrderChanged(getBarChartOrder());
    emit updateIntervalChanged(getUpdateInterval());
    emit rotateChanged(getRotate());
    emit showEmptyChannelsChanged(getShowEmptyChannels());
    emit magneticDeclinationChanged(getMagneticDeclination());
}
