import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

Item {
    property PositionSource positionSource

    PullDownMenu {
        MenuItem {
            text: qsTr("About")
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/AboutPage.qml"))
        }
        MenuItem {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"))
        }
        MenuItem {
            text: positionSource.active ? qsTr("Deactivate GPS") : qsTr("Activate GPS")
            onClicked: {
                providers.toggleActive()
            }
        }
        MenuItem {
            enabled: gpsDataSource.active
            text: qsTr("Copy location")
            onClicked: {
                if (settings.coordinateFormat === "DEG") {
                    Clipboard.text = LocationFormater.decimalLatToDMS(positionSource.position.coordinate.latitude, 2)
                            + ", "
                            + LocationFormater.decimalLongToDMS(positionSource.position.coordinate.longitude, 2);
                } else {
                    Clipboard.text = positionSource.position.coordinate.latitude
                            + ", "
                            + positionSource.position.coordinate.longitude
                }
            }
        }
    }
}
