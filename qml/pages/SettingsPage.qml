import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: settingsPage

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    states: [
        State {
            name: 'landscape';
            when: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted;
            PropertyChanges {
                target: listView;
                anchors.leftMargin: settingsPage.width * 0.125;
                anchors.rightMargin: settingsPage.width * 0.125;
            }
        }
    ]

    function setSpeedUnitComboBoxIndex() {
        if (settings.units === "MET") {
            speedUnitComboBox.currentIndex = settings.speedUnit === "SEC" ? 0 : 1
        } else {
            speedUnitComboBox.currentIndex = settings.speedUnit === "SEC" ? 2 : 3
        }

    }

    function setLanguageCombobox() {
        return settings.locale === "ru" ? 1 : 0
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Settings")
        }
        model: VisualItemModel {
            ComboBox {
                label: qsTr("Coordinate format")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("degree")
                        onClicked: settings.coordinateFormat = "DEG"
                    }
                    MenuItem {
                        text: qsTr("decimal")
                        onClicked: settings.coordinateFormat = "DEC"
                    }
                    MenuItem {
                        text: qsTr("UTM")
                        onClicked: settings.coordinateFormat = "UTM"
                    }
                }
                Component.onCompleted: currentIndex = settings.coordinateFormat === "DEG" ? 0
                                                      : (settings.coordinateFormat === "UTM" ? 2 : 1)
            }
            ComboBox {
                label: qsTr("Units")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("metric")
                        onClicked: {
                            settings.units = "MET";
                            setSpeedUnitComboBoxIndex();
                        }
                    }
                    MenuItem {
                        text: qsTr("imperial")
                        onClicked: {
                            settings.units = "IMP";
                            setSpeedUnitComboBoxIndex();
                        }
                    }
                }
                Component.onCompleted: currentIndex = settings.units === "MET" ? 0 : 1
            }
            ComboBox {
                id: speedUnitComboBox
                label: qsTr("Speed")
                menu: ContextMenu {
                    MenuItem {
                        visible: settings.units === "MET"
                        text: qsTr("m/s")
                        onClicked: settings.speedUnit = "SEC"
                    }
                    MenuItem {
                        visible: settings.units === "MET"
                        text: qsTr("km/h")
                        onClicked: settings.speedUnit = "HOUR"
                    }
                    MenuItem {
                        visible: settings.units === "IMP"
                        text: qsTr("ft/s")
                        onClicked: settings.speedUnit = "SEC"
                    }
                    MenuItem {
                        visible: settings.units === "IMP"
                        text: qsTr("mph")
                        onClicked: settings.speedUnit = "HOUR"
                    }
                }
                Component.onCompleted: setSpeedUnitComboBoxIndex()
            }
            ComboBox {
                id: languageCombobox
                label: qsTr("Language")
                menu: ContextMenu {
                    MenuItem { text: "English"; onClicked: settings.locale = "en"; }
                    MenuItem { text: "Pусский"; onClicked: settings.locale = "ru"; }
                }
                Component.onCompleted: currentIndex = setLanguageCombobox()
                description: qsTr("Requires app restart")
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium * 2
                text: qsTr("Update interval")
            }

            Slider {
                minimumValue: 1
                maximumValue: 120
                stepSize: 1
                value: settings.updateInterval
                valueText: value + "s"
                width: parent.width
                onReleased: settings.updateInterval = value
            }
            TextField {
                id: declinationField
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Magnetic Declination")
                text: settings.magneticDeclination
                placeholderText: qsTr("Local declination")
                validator: DoubleValidator {
                    bottom: -180
                    top: 180
                    decimals: 1
                }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked:  {focus = false
                    settings.magneticDeclination = parseFloat(text)
                }
                function setDeclination(Dec) {
                    settings.magneticDeclination = Dec
                }
            }

            ComboBox {
                label: qsTr("Rotate satellite view")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        onClicked: {
                            settings.rotate = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("no")
                        onClicked: {
                            settings.rotate = false;
                        }
                    }
                }
                Component.onCompleted: currentIndex = settings.rotate ? 0 : 1
            }
            ComboBox {
                label: qsTr("Show movement direction")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        onClicked: {
                            settings.showDirectionIndicator = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("no")
                        onClicked: {
                            settings.showDirectionIndicator = false;
                        }
                    }
                }
                Component.onCompleted: currentIndex = settings.showDirectionIndicator ? 0 : 1
            }
            ComboBox {
                label: qsTr("Show magnetic north")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        onClicked: {
                            settings.showMagneticNorth = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("no")
                        onClicked: {
                            settings.showMagneticNorth = false;
                        }
                    }
                }
                Component.onCompleted: currentIndex = settings.showMagneticNorth ? 0 : 1
            }
            ComboBox {
                label: qsTr("Show empty channels")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        onClicked: {
                            settings.showEmptyChannels = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("no")
                        onClicked: {
                            settings.showEmptyChannels = false;
                        }
                    }
                }
                Component.onCompleted: currentIndex = settings.showEmptyChannels ? 0 : 1
            }

            ComboBox {
                label: qsTr("Satellite bar chart order")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("identifier","'Number' of the satellite")
                        onClicked: {
                            settings.barChartOrder = "id";
                        }
                    }
                    MenuItem {
                        text: qsTr("signal strength")
                        onClicked: {
                            settings.barChartOrder = "signal";
                        }
                    }
                }
                Component.onCompleted: currentIndex = (settings.barChartOrder === "id" ? 0 : 1)
            }

            Item {
                width: parent.width
                height: Theme.iconSizeLarge * 1.2
                Label {
                    id: showLabel
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: qsTr("Show") + "..."
                }
                Label {
                    id: appviewLabel
                    anchors.verticalCenter: parent.verticalCenter
                    x: gpsSwitches.lSw.x + gpsSwitches.lSw.width / 2 - width / 2
                    text: qsTr("Appview")
                }
                Label {
                    id: coverLabel
                    anchors.verticalCenter: parent.verticalCenter
                    x: gpsSwitches.rSw.x + gpsSwitches.rSw.width / 2 - width / 2
                    text: qsTr("Cover")
                }
            }

            DoubleSwitch {
                id: gpsSwitches
                text: qsTr("GPS state")
                lSw.checked:   settings.showGpsStateApp
                lSw.onClicked: settings.showGpsStateApp = lSw.checked
                rSw.checked:   settings.showGpsStateCover
                rSw.onClicked: settings.showGpsStateCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Latitude")
                lSw.checked:   settings.showLatitudeApp
                lSw.onClicked: settings.showLatitudeApp = lSw.checked
                rSw.checked:   settings.showLatitudeCover
                rSw.onClicked: settings.showLatitudeCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Longitude")
                lSw.checked:   settings.showLongitudeApp
                lSw.onClicked: settings.showLongitudeApp = lSw.checked
                rSw.checked:   settings.showLongitudeCover
                rSw.onClicked: settings.showLongitudeCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Altitude")
                lSw.checked:   settings.showAltitudeApp
                lSw.onClicked: settings.showAltitudeApp = lSw.checked
                rSw.checked:   settings.showAltitudeCover
                rSw.onClicked: settings.showAltitudeCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Speed")
                lSw.checked:   settings.showSpeedApp
                lSw.onClicked: settings.showSpeedApp = lSw.checked
                rSw.checked:   settings.showSpeedCover
                rSw.onClicked: settings.showSpeedCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Movement Direction")
                lSw.checked:   settings.showMovementDirectionApp
                lSw.onClicked: settings.showMovementDirectionApp = lSw.checked
                rSw.checked:   settings.showMovementDirectionCover
                rSw.onClicked: settings.showMovementDirectionCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Last Update")
                lSw.checked:   settings.showLastUpdateApp
                lSw.onClicked: settings.showLastUpdateApp = lSw.checked
                rSw.checked:   settings.showLastUpdateCover
                rSw.onClicked: settings.showLastUpdateCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Vertical Accuracy")
                lSw.checked:   settings.showVerticalAccuracyApp
                lSw.onClicked: settings.showVerticalAccuracyApp = lSw.checked
                rSw.checked:   settings.showVerticalAccuracyCover
                rSw.onClicked: settings.showVerticalAccuracyCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Horizontal Accuracy")
                lSw.checked:   settings.showHorizontalAccuracyApp
                lSw.onClicked: settings.showHorizontalAccuracyApp = lSw.checked
                rSw.checked:   settings.showHorizontalAccuracyCover
                rSw.onClicked: settings.showHorizontalAccuracyCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Satellite Info")
                lSw.checked:   settings.showSatelliteInfoApp
                lSw.onClicked: settings.showSatelliteInfoApp = lSw.checked
                rSw.checked:   settings.showSatelliteInfoCover
                rSw.onClicked: settings.showSatelliteInfoCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Compass Direction")
                lSw.checked:   settings.showCompassDirectionApp
                lSw.onClicked: settings.showCompassDirectionApp = lSw.checked
                rSw.checked:   settings.showCompassDirectionCover
                rSw.onClicked: settings.showCompassDirectionCover = rSw.checked
            }

            DoubleSwitch {
                text: qsTr("Compass Calibration")
                lSw.checked:   settings.showCompassCalibrationApp
                lSw.onClicked: settings.showCompassCalibrationApp = lSw.checked
                rSw.checked:   settings.showCompassCalibrationCover
                rSw.onClicked: settings.showCompassCalibrationCover = rSw.checked
            }

            Button {
                text: qsTr("Reset settings")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: settings.resetToDefaults()
            }

        }
    }
}
