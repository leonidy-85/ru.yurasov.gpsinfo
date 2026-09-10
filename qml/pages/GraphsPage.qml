import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../tabview" as Tabs

Tabs.TabItem {
    id: graphsPage
    anchors.fill: parent
    flickable: flickable

    AppBarMenu {
        property string namePage: "Graphs"
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: pageHeader.height + column.height + Theme.paddingLarge

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
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }

            GraphItem {
                width: parent.width
                title: qsTr("Speed")
                unit: "m/s"
                values: providers.history.speed
                lineColor: "#4fc3f7"
            }
            GraphItem {
                width: parent.width
                title: qsTr("Altitude")
                unit: "m"
                values: providers.history.altitude
                lineColor: "#81c784"
            }
            GraphItem {
                width: parent.width
                title: qsTr("Horizontal accuracy")
                unit: "m"
                values: providers.history.horizontalAccuracy
                lineColor: "#ffb74d"
            }
            GraphItem {
                width: parent.width
                title: qsTr("Satellites in use")
                unit: ""
                values: providers.history.satellites
                lineColor: "#ba68c8"
            }
            GraphItem {
                width: parent.width
                title: qsTr("Signal strength (max / avg)")
                unit: ""
                values: providers.history.signalMax
                values2: providers.history.signalAvg
                lineColor: "#e57373"
                lineColor2: "#64b5f6"
            }
        }
    }
}
