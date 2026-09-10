import QtQuick 2.0
import QtPositioning 5.2
import QtSensors 5.0
import Yurasov.GPSInfo 1.0
import Sailfish.Silica 1.0
import "../components"


Item {
    id: providers
    property alias position: positionSource
    property alias compass: compass
    property alias gps: gpsDataSource
    property alias timing: timing
    property alias trackRecorder: trackRecorder
    property alias history: history
    function toggleActive() {
        if (positionSource.active) {
            console.log("deactivating GPS");
            positionSource.stop();
            gpsDataSource.active = false;
        } else {
            console.log("activating GPS");
            positionSource.start();
            gpsDataSource.active = true;
        }

    }

    PositionSource {
        id: positionSource
        updateInterval: settings.updateInterval * 1000
        active: true
        //timestamp seems to be the only way to know gps has a new fix
        position.onTimestampChanged: {
            if (position.coordinate.isValid) {
                timing.setTimeToFirstFix()
                trackRecorder.addPosition(position.coordinate.latitude,
                                          position.coordinate.longitude,
                                          position.coordinate.altitude,
                                          position.timestamp)
            }
        }
    }

    Compass {
        id: compass
        active: true
    }

    TrackRecorder {
        id: trackRecorder
    }

    QtObject {
        id: history
        property var speed: []
        property var altitude: []
        property var horizontalAccuracy: []
        property var satellites: []
        property var signalMax: []
        property var signalAvg: []
        readonly property int maxPoints: 120
        function pushSample(array, value) {
            var result = array.slice()
            result.push(value)
            while (result.length > maxPoints)
                result.shift()
            return result
        }
    }

    Timer {
        id: historyTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!positionSource.position.coordinate.isValid)
                return
            history.speed = history.pushSample(history.speed, positionSource.position.speedValid ? positionSource.position.speed : 0)
            history.altitude = history.pushSample(history.altitude, positionSource.position.altitudeValid ? positionSource.position.coordinate.altitude : 0)
            history.horizontalAccuracy = history.pushSample(history.horizontalAccuracy, positionSource.position.horizontalAccuracyValid ? positionSource.position.horizontalAccuracy : 0)
            history.satellites = history.pushSample(history.satellites, gpsDataSource.numberOfUsedSatellites)
            var list = gpsDataSource.satellites
            var maxSignal = 0, sum = 0, count = 0
            for (var i = 0; i < list.length; i++) {
                var signal = list[i].signalStrength
                if (signal > maxSignal)
                    maxSignal = signal
                sum += signal
                count++
            }
            history.signalMax = history.pushSample(history.signalMax, maxSignal)
            history.signalAvg = history.pushSample(history.signalAvg, count > 0 ? sum / count : 0)
        }
    }

    GPSDataSource {
        id: gpsDataSource
        updateIntervalMs: settings.updateInterval * 1000
        active: true
        Component.onCompleted:{ //as onActiveChanged is not fired at startup
            onActiveChanged(null)
        }

        onActiveChanged: {
            if (active) {
                timing.start()
            }
        }
        //onNumberOfUsedSatellitesChanged: console.log("ousc")

    }
    Item {
        id: timing
        property date gpsActivationTime: new Date()
        property date lastPositionTimestamp: positionSource.position.timestamp //new Date()

        property bool pendingFix: true
        property int secondsToLocationFix: 0
        property int secondsSinceLastLocationFix: 0

        Timer { //keep secsXX running when no position updates
            id: timer
            interval: 1000;
            running: true
            repeat: true;
            onTriggered: {
                //console.log("tick")
                timing.secondsSinceLastLocationFix = Math.round((new Date() - timing.lastPositionTimestamp)/1000)
                if (timing.pendingFix) {
                    timing.secondsToLocationFix = Math.round(-(new Date() - timing.gpsActivationTime)/1000);
                }
            }
        }
        function start() {
            gpsActivationTime = new Date()
            lastPositionTimestamp = positionSource.position.timestamp
            pendingFix =true
            secondsToLocationFix = 0
            console.log("c "+pendingFix)
        }

        function setTimeToFirstFix() {
            secondsSinceLastLocationFix = Math.round((positionSource.position.timestamp - lastPositionTimestamp)/1000)
            lastPositionTimestamp = positionSource.position.timestamp
            if (pendingFix) {
                secondsToLocationFix = Math.round((new Date() - gpsActivationTime)/1000)
                pendingFix=false
                Notices.show(qsTr("Time to First Fix") + ": " + secondsToLocationFix + "s", Notice.Long)
            }

        }
        function formatElapsedTime(t) { //print fn for elapsed times
            if (t<=90) return Math.round(t)+ "sec"
            t=t/60;
            if (t<=90) return locationFormatter.roundToDecimal(t,1)+ "min"
            t=t/60;
            return locationFormatter.roundToDecimal(t,1)+ "hr"
        }
    }
}
