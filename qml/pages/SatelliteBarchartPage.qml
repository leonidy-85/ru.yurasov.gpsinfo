import QtQuick 2.6
import Sailfish.Silica 1.0
import "../QChart"   //must init and update the submodule "git submodule update --init"
import "../components"
import "../tabview" as Tabs


Tabs.TabItem  {
    id: satelliteBarchartPage

    property real topMargin

    anchors.fill: parent
    flickable: flickable

    AppBarMenu {
          property string namePage: "Satellite signal strengths"
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PageHeader {
                id: header
            }

            Item {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                QChart {
                    id: rssiBarChart;
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    height: tabMainPage.isPortrait ? width : parent.height - 2 * Theme.horizontalPageMargin
                    anchors.centerIn: parent
                    chartType: Charts.ChartType.BAR
                    property variant satellites: status === PageStatus.Inactive ? [] : providers.gps.satellites;
                    property bool componentLoaded: false
                    // Initialised declaratively so the first paint always has valid data.
                    chartData: ({
                        labels: [],
                        labelColors: [],
                        datasets: [{
                                data: [],
                                fillColor: [],
                                barStrokeWidth: [],
                                strokeColor: []
                            }]
                    })
                    chartOptions: ({
                        scaleStartValue: 0,
                        scaleStepWidth: 5,
                        scaleSteps: 10,
                        scaleOverride: true,
                        scaleFontColor: Theme.secondaryHighlightColor,
                        scaleFontSize: Theme.fontSizeSmall,
                        scaleFontFamily: Theme.fontFamily,
                        scaleLineColor: Theme.rgba(Theme.highlightColor, Theme.highlightBackgroundOpacity),
                        scaleLineWidth: Theme.fontSizeTiny / 10.0,
                        scaleGridLineColor: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity),
                        scaleGridLineWidth: Theme.fontSizeTiny / 10.0
                    })
                    Component.onCompleted: {
                        rssiBarChart.componentLoaded = true
                    }

                    function getRSSI_Color(rssi, opacity)
                    {
                        return "hsla(" + (rssi < 40 ? rssi : 40) * 3 + ",100%,35%," + opacity + ")";
                    }

                    onSatellitesChanged: {
                        if (!rssiBarChart.componentLoaded || pageStack.currentPage !== tabMainPage)
                            return;

                        var results = providers.gps.satellites;

                        if(results.length > 0) {
                            // Sort satellites by signal strength
                            if(settings.barChartOrder === "signal")
                                results.sort(function(a,b) {return b.signalStrength - a.signalStrength})

                            // Clear the chart data
                            rssiBarChart.chartData.labels = []
                            rssiBarChart.chartData.labelColors = []
                            rssiBarChart.chartData.datasets[0].data = []
                            rssiBarChart.chartData.datasets[0].fillColor = []
                            // Insert the data
                            results.forEach(function(barSat) {
                                rssiBarChart.chartData.labels.push(barSat.identifier);
                                rssiBarChart.chartData.labelColors.push(barSat.inUse ? Theme.highlightColor : Theme.secondaryColor);

                                rssiBarChart.chartData.datasets[0].data.push(barSat.signalStrength);
                                rssiBarChart.chartData.datasets[0].fillColor.push(getRSSI_Color(barSat.signalStrength, barSat.inUse ? 1.0 : 0.75))
                                rssiBarChart.chartData.datasets[0].barStrokeWidth.push(barSat.inUse ? (Theme.iconSizeExtraSmall / 5.0) : 0.0);
                                rssiBarChart.chartData.datasets[0].strokeColor.push(barSat.inUse ? "white" : "transparent");
                            });

                            // Draw minimum of 5 (10) bars in portrait (landscape)
                            var additionalBars = 0
                            if(tabMainPage.isPortrait && results.length < 5)
                                additionalBars = 5 - results.length
                            else if(tabMainPage.isLandscape && results.length < 10)
                                additionalBars = 10 - results.length

                            while(additionalBars > 0){
                                rssiBarChart.chartData.labels.push(" ");
                                rssiBarChart.chartData.datasets[0].data.push(0);
                                rssiBarChart.chartData.datasets[0].fillColor.push("transparent");
                                additionalBars--
                            }
                        }
                        rssiBarChart.requestPaint();
                    }
                }
            }
        InfoField {
            id: satellitesInfo
            label: qsTr("Satellites in use / view")
            value: providers.gps.active ? providers.gps.numberOfUsedSatellites + " / " + providers.gps.numberOfVisibleSatellites : "-"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            visible: tabMainPage.isPortrait
        }
    }
}
