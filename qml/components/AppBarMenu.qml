import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import Aurora.Controls 1.0


    AppBar {
        id: topAppBar

        property ShareAction shareLocation: ShareAction {
            title: qsTr("GPSInfo")
        }
        headerText: namePage === "GPSInfo" ? qsTr("GPSInfo")
                  : namePage === "Satellite Info" ? qsTr("Satellite Info")
                  : namePage === "Satellite signal strengths" ? qsTr("Satellite signal strengths")
                  : namePage === "Graphs" ? qsTr("Graphs")
                  : ""
//        if (namePage===2)
//        headerText: qsTr("Satellite signal strengths")
//        if (namePage===3)
//        headerText: qsTr("GPSInfo3")

        headerClickable: false
        visible: opacity > 0
        Behavior on opacity { FadeAnimation {} }


               AppBarSpacer {}

                AppBarButton {
                  id: appBarMenuButton
                  icon.source: "image://theme/icon-m-more"
                  onClicked: mainPopup.open()

                  PopupMenu {
                      id: mainPopup
                      PopupMenuItem {
                          text: qsTr("About")
                          onClicked: pageStack.push(Qt.resolvedUrl("../pages/AboutPage.qml"))
                      }

                      PopupMenuItem {
                          text: qsTr("Settings")
                          onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"))
                      }

                      PopupMenuItem {
                          text: providers.position.active ? qsTr("Deactivate GPS") : qsTr("Activate GPS")
                          onClicked: {
                              providers.toggleActive()
                          }
                      }

                      PopupMenuItem {
                      enabled: providers.gps.active
                      text: qsTr("Copy location")
                      onClicked: {
                          if (settings.coordinateFormat === "DEG") {
                              Clipboard.text = locationFormatter.decimalLatToDMS(providers.position.position.coordinate.latitude, 2)
                                      + ", "
                                      + locationFormatter.decimalLongToDMS(providers.position.position.coordinate.longitude, 2);
                          } else if (settings.coordinateFormat === "UTM") {
                              Clipboard.text = locationFormatter.decimalToUTM(providers.position.position.coordinate.latitude,
                                                                             providers.position.position.coordinate.longitude);
                          } else {
                              Clipboard.text = providers.position.position.coordinate.latitude
                                      + ", "
                                      + providers.position.position.coordinate.longitude
                           }
                         }
                       }

                      PopupMenuItem {
                          text: qsTr("Share location")
                          enabled: providers.position.position.coordinate.isValid
                          onClicked: {
                              var coordinate = providers.position.position.coordinate;
                              var text;
                              if (settings.coordinateFormat === "DEG") {
                                  text = locationFormatter.decimalLatToDMS(coordinate.latitude, 2)
                                       + ", "
                                       + locationFormatter.decimalLongToDMS(coordinate.longitude, 2);
                              } else if (settings.coordinateFormat === "UTM") {
                                  text = locationFormatter.decimalToUTM(coordinate.latitude, coordinate.longitude);
                              } else {
                                  text = coordinate.latitude + ", " + coordinate.longitude;
                              }
                              topAppBar.shareLocation.resources = [{ "type": "text/plain",
                                                                     "status": text + "\ngeo:" + coordinate.latitude + "," + coordinate.longitude }];
                              topAppBar.shareLocation.trigger();
                          }
                      }

                      PopupMenuItem {
                          text: providers.trackRecorder.recording ? qsTr("Stop track") : qsTr("Start track")
                          onClicked: providers.trackRecorder.recording ? providers.trackRecorder.stop()
                                                                      : providers.trackRecorder.start()
                      }

                      PopupMenuItem {
                          text: qsTr("Save track")
                          enabled: providers.trackRecorder.pointCount > 0
                          onClicked: {
                              var path = providers.trackRecorder.save();
                              if (path !== "")
                                  Notices.show(qsTr("Track saved") + ": " + path, Notice.Short);
                          }
                      }
                  }

              }
                AppBarSpacer {
                fixedWidth : 25
                }

          }


