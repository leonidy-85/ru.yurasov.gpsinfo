// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../tabview" as Tabs

Page {
    id: tabMainPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    property bool footerPosition: true // set here true of false to change tabs postions from top to bottom
    property bool noTitle
    property bool noIcon
    property int display: 8
    readonly property string labelText: qsTr("GPSInfo")

    backNavigation: false

    Tabs.TabView {
        id: tabs

        property var _viewModel: [mainPage, satelliteInfoPage, barchartPage]
        width: parent.width
        height: tabMainPage.height

        header: tabMainPage.footerPosition ? null : tabBar
        footer: tabMainPage.footerPosition ? tabBar : null

        model: _viewModel.slice(0, tabMainPage.display)

        Component {
            id: tabBar

            Tabs.TabBar {
                model: tabModel
            }
        }

        Component {
            id: mainPage

            FirstPage {
                topMargin: tabMainPage.footerPosition ? 0 : tabs.tabBarHeight
            }
        }

        Component {
            id: satelliteInfoPage

            SatelliteInfoPage {
//                topMargin: radarPage.footerPosition ? 0 : tabs.tabBarHeight
            }

        }

        Component {
            id: barchartPage

            SatelliteBarchartPage {
//                topMargin: satelliteBarchartPage.footerPosition ? 0 : tabs.tabBarHeight
            }
        }


    }

    Component.onCompleted: {
        prepareModel()
    }

    function prepareModel() {
        if (tabMainPage.display < tabModel.count) {
            tabModel.remove(tabMainPage.display, tabModel.count - tabMainPage.display)
        }
        for (var i = 0; i < tabModel.count; i++) {
            if (tabMainPage.noTitle) {
                tabModel.setProperty(i, "title", "")
            }
            if (tabMainPage.noIcon) {
                tabModel.setProperty(i, "icon", "")
            }
        }
    }

    ListModel {
        id: tabModel

        ListElement {
            title: qsTr("GPSInfo")
            icon: "image://theme/icon-m-gps"
            count: 0
        }
        ListElement {
            title: qsTr("radarPage")
            icon: "image://theme/icon-m-location"
            count: 0
        }
        ListElement {
            title: qsTr("barchartPage")
            icon: "image://theme/icon-m-wlan-2"
            count: 0
        }
//        ListElement {
//            title: qsTr("Tab button 4")
//            icon: "image://theme/icon-m-contact"
//            count: 0
//        }
//        ListElement {
//            title: qsTr("Tab button 5")
//            icon: "image://theme/icon-m-dialpad"
//            count: 0
//        }
//        ListElement {
//            title: qsTr("Tab button 6")
//            icon: "image://theme/icon-m-file-vcard"
//            count: 0
//        }
//        ListElement {
//            title: qsTr("Tab button 7")
//            icon: "image://theme/icon-m-developer-mode"
//            count: 0
//        }
//        ListElement {
//            title: qsTr("Tab button 8")
//            icon: "image://theme/icon-m-note"
//            count: 0
//        }
    }
}
