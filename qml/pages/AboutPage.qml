import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: aboutPage

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    onStatusChanged: {
        if(status === PageStatus.Active)
            pageStack.pushAttached(Qt.resolvedUrl("LicensePage.qml"))
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height
        VerticalScrollDecorator {}

        Column {
            id: col
            spacing: 20
            width: parent.width

            SectionHeader {
                text: qsTr("About")
            }

            Label {
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GPSInfo"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/ru.yurasov.gpsinfo"
                width: Theme.iconSizeExtraLarge
                height: Theme.iconSizeExtraLarge
                smooth: true
                asynchronous: true
                onStatusChanged: if (status === Image.Error) source = "image://theme/icon-m-gps"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                text: qsTr("An app to show all position information")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: qsTr("Version ") + version
            }
            Item {
              width: parent.width
              height: Theme.paddingLarge
            }

            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
            }
            SectionHeader {
                text: qsTr("Donate")
            }
            AboutLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text:  qsTr("Your help allows us to make this project better.")
            }

            AboutLabel {
                id: ymoney
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("If you like the app, you can donate to the author of the app via ")+ "<a href=\"https://forms.yandex.ru/u/66d272b8068ff021f89c2953/\">ЮMoney </a>" + qsTr(" or ")+ "<a href=\"https://boosty.to/ub3gad/donate\"> Boosty</a>"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Item {
              width: parent.width
              height: Theme.paddingLarge
            }

            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
            }
            SectionHeader {
                text: qsTr("Author")
            }
            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Aurora adaptation, development and improvements by Leonid Yurasov — this is not just a port, the app is being actively refined.")
            }
            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Other programs by the author: ") + "<a href=\"https://github.com/leonidy-85\">github.com/leonidy-85</a>"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(link)
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "Copyright © 2014-2016 Marcel Witte\n"+
                      "2019 Miklós Márton\n"+
                      "2019 Matti Lehtimäki\n"+
                      "2019-2022 Matti Viljanen"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("For suggestions, bugs and ideas visit ")
            }

            Button {
                text: "GitHub"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: Qt.openUrlExternally("https://github.com/leonidy-85/ru.yurasov.gpsinfo")
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
        }
    }
}
