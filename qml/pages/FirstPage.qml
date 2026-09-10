import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../tabview" as Tabs

Tabs.TabItem  {
    id: root
    property real topMargin
    anchors.fill: parent
    flickable: flickable

    AppBarMenu {
          property string namePage: "GPSInfo"
    }


//    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    states: [
        State {
            name: 'landscape';
            when: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted;
            PropertyChanges {
                target: column;
                anchors.leftMargin: root.width * 0.125;
                anchors.rightMargin: root.width * 0.125;
            }
        }
    ]
//    property bool radarPagePushed: false
//    onStatusChanged: {
//        if(!radarPagePushed && status === PageStatus.Active) {
//            pageStack.pushAttached(radarPage)
//            radarPagePushed = true
//        }
//        if(!radarPage.barchartPagePushed && status === PageStatus.Inactive) {
//            radarPage.pagePushTimer.start()
//        }
//    }

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: pageHeader.height + column.height;

        PageHeader {
            id: pageHeader
        }


        Column {
            id: column
            spacing: Theme.paddingLarge

            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                leftMargin: 0
                rightMargin: Theme.paddingSmall
            }

            InfoField {
                label: qsTr("GPS")
                visible: settings.showGpsStateApp
                value: providers.position.active ? qsTr("active") : qsTr("inactive")
            }
            InfoField {
                label: qsTr("Latitude")
                visible: settings.showLatitudeApp
                value: {
                    if (providers.position.position.latitudeValid) {
                        if (settings.coordinateFormat === "DEG") {
                            return locationFormatter.decimalLatToDMS(providers.position.position.coordinate.latitude, 2)
                        } else {
                            return providers.position.position.coordinate.latitude
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Longitude")
                visible: settings.showLongitudeApp
                value: {
                    if (providers.position.position.longitudeValid) {
                        if (settings.coordinateFormat === "DEG") {
                            return locationFormatter.decimalLongToDMS(providers.position.position.coordinate.longitude, 2)
                        } else {
                            return providers.position.position.coordinate.longitude
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Altitude")
                visible: settings.showAltitudeApp
                value: {
                    if (providers.position.position.altitudeValid) {
                        if (settings.units === "MET") {
                            return locationFormatter.roundToDecimal(providers.position.position.coordinate.altitude, 2) + " m"
                        } else {
                            return locationFormatter.roundToDecimal(providers.position.position.coordinate.altitude * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Speed")
                visible: settings.showSpeedApp
                value: {
                    if (providers.position.position.speedValid) {
                        if (settings.units === "MET") {
                            if (settings.speedUnit === "SEC") {
                                return locationFormatter.roundToDecimal(providers.position.position.speed, 2) + " " + qsTr("m/s")
                            } else {
                                return locationFormatter.roundToDecimal(providers.position.position.speed * 60 * 60 / 1000, 2) + " " + qsTr("km/h")
                            }
                        } else {
                            if (settings.speedUnit === "SEC") {
                                return locationFormatter.roundToDecimal(providers.position.position.speed * 3.2808399, 2) + " " + qsTr("ft/s")
                            } else {
                                return locationFormatter.roundToDecimal(providers.position.position.speed * 2.23693629, 2) + " " + qsTr("mph")
                            }
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Movement direction")
                visible: settings.showMovementDirectionApp
                value: isNaN(providers.gps.movementDirection) ? "-" : locationFormatter.formatDirection(providers.gps.movementDirection)
            }
            InfoField {
                label: qsTr("Last update")
                visible: settings.showLastUpdateApp
                // If more than a few secs then also show elapsed time.
                // Always show actual time at the end.
                value: ((providers.timing.secondsSinceLastLocationFix > (1 + settings.updateInterval))
                        ? "-" + providers.timing.formatElapsedTime(providers.timing.secondsSinceLastLocationFix)
                        : "")
                       + " "
                       + (providers.position.position.coordinate.isValid
                          ? Qt.formatTime(providers.position.position.timestamp, "hh:mm:ss")
                          : "-")
            }
            InfoField {
                label: qsTr("Time to First Fix")
                visible: settings.showLastUpdateApp
                value: providers.timing.formatElapsedTime(providers.timing.secondsToLocationFix)
                highlight: providers.timing.secondsToLocationFix < 0
            }

            InfoField {
                label: qsTr("Vertical accuracy")
                visible: settings.showVerticalAccuracyApp
                value: {
                    if (providers.position.position.verticalAccuracyValid) {
                        if (settings.units === "MET") {
                            return locationFormatter.roundToDecimal(providers.position.position.verticalAccuracy, 2) + " m"
                        } else {
                            return locationFormatter.roundToDecimal(providers.position.position.verticalAccuracy * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Horizontal accuracy")
                visible: settings.showHorizontalAccuracyApp
                value: {
                    if (providers.position.position.horizontalAccuracyValid) {
                        if (settings.units === "MET") {
                            return locationFormatter.roundToDecimal(providers.position.position.horizontalAccuracy, 2) + " m"
                        } else {
                            return locationFormatter.roundToDecimal(providers.position.position.horizontalAccuracy * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Satellites in use / view")
                visible: settings.showSatelliteInfoApp
                value: providers.gps.active ? providers.gps.numberOfUsedSatellites + " / " + providers.gps.numberOfVisibleSatellites : "-"
            }
            SectionHeader {
                text: qsTr("Compass")
            }
            InfoField {
                label: qsTr("Direction")
                visible: settings.showCompassDirectionApp
                value: providers.compass.reading == null ? "-" : locationFormatter.formatDirection(providers.compass.reading.azimuth)
            }
            InfoField {
                label: qsTr("Calibration")
                visible: settings.showCompassCalibrationApp
                value: providers.compass.reading == null ? "-" : Math.round(providers.compass.reading.calibrationLevel * 100) + "%"
            }
            InfoField { // Needs QtPositioning 5.4
                label: qsTr("Magnetic Declination")
                visible: settings.showCompassDirectionApp
                value: {
                    if(typeof providers.position.position.magneticVariationValid !== undefined) {
                        if (providers.position.position.magneticVariationValid === true) {
                            return locationFormatter.roundToDecimal(providers.position.position.magneticVariation, 1)
                        }
                        return "-"
                    }
                    return "N/A"
                }
            }

            // This element is "necessary", because Sony Xperia XA2 Ultra (at least)
            // messes up the column height calculation with only InfoFields...
            Rectangle {
                color: "transparent"
                width: parent.width
                height: 1.0
            }
        }
    }

    ListModel {
            id: tabModel

            ListElement {
                //% "Favorites"
                title: qsTrId("contacts-mp-favorites")
                icon: "image://theme/icon-splus-favorite"
            }
            ListElement {
                //% "Contacts"
                title: qsTrId("contacts-mp-contacts")
                icon: "image://theme/icon-splus-contact"
            }
        }
}
