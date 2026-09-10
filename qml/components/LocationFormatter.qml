import QtQuick 2.0

Item {
    property string mag: qsTr("M", "Magnetic North")

    property string north: qsTr("N", "North")
    property string south: qsTr("S", "South")
    property string east: qsTr("E", "East")
    property string west: qsTr("W", "West")

    function roundToDecimal(inputNum, numPoints) {
        var multiplier = Math.pow(10, numPoints);
        return Math.round(inputNum * multiplier) / multiplier;
    }

    function decimalToDMS(location, hemisphere, numSecondPoints) {
        if(location < 0) {
            location *= -1
        }
        var degrees = Math.floor(location);
        var minutesFromRemainder = (location - degrees) * 60;
        var minutes = Math.floor(minutesFromRemainder);
        var secondsFromRemainder = (minutesFromRemainder - minutes) * 60;
        var seconds = roundToDecimal(secondsFromRemainder, numSecondPoints);
        return degrees + '° ' + minutes + "' " + seconds + '" ' + hemisphere;
    }

    function decimalLatToDMS(location, numSecondPoints) {
        var hemisphere = (location < 0) ? south: north;
        return decimalToDMS(location, hemisphere, numSecondPoints);
    }

    function decimalLongToDMS(location, numSecondPoints) {
        var hemisphere = (location < 0) ? west : east;
        return decimalToDMS(location, hemisphere, numSecondPoints);
    }

    // WGS84 forward projection to UTM (returns "33U 456789 6123456").
    function decimalToUTM(latitude, longitude) {
        var a = 6378137.0;
        var f = 1.0 / 298.257223563;
        var e2 = f * (2 - f);
        var k0 = 0.9996;
        var latRad = latitude * Math.PI / 180;
        var lonRad = longitude * Math.PI / 180;
        var zone = Math.floor((longitude + 180) / 6) + 1;
        var lonOriginRad = ((zone - 1) * 6 - 180 + 3) * Math.PI / 180;
        var ep2 = e2 / (1 - e2);
        var N = a / Math.sqrt(1 - e2 * Math.sin(latRad) * Math.sin(latRad));
        var T = Math.tan(latRad) * Math.tan(latRad);
        var C = ep2 * Math.cos(latRad) * Math.cos(latRad);
        var A = Math.cos(latRad) * (lonRad - lonOriginRad);
        var M = a * ((1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256) * latRad
                - (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) * Math.sin(2 * latRad)
                + (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) * Math.sin(4 * latRad)
                - (35 * e2 * e2 * e2 / 3072) * Math.sin(6 * latRad));
        var easting = k0 * N * (A + (1 - T + C) * A * A * A / 6
                + (5 - 18 * T + T * T + 72 * C - 58 * ep2) * A * A * A * A * A / 120) + 500000.0;
        var northing = k0 * (M + N * Math.tan(latRad) * (A * A / 2
                + (5 - T + 9 * C + 4 * C * C) * A * A * A * A / 24
                + (61 - 58 * T + T * T + 600 * C - 330 * ep2) * A * A * A * A * A * A / 720));
        if (latitude < 0)
            northing += 10000000.0;
        var band = "CDEFGHJKLMNPQRSTUVWX".charAt(Math.floor((latitude + 80) / 8));
        return zone + band + " " + Math.round(easting) + " " + Math.round(northing);
    }

    function formatDirection(direction) {
        var dirStr;
        if (direction < 11.25) {
            dirStr = north
        } else if (direction < 33.75) {
            dirStr = qsTr("NNE", "North North East")
        } else if (direction < 56.25) {
            dirStr = qsTr("NE", "North East")
        } else if (direction < 78.75) {
            dirStr = qsTr("ENE", "East North East")
        } else if (direction < 101.25) {
            dirStr = east
        } else if (direction < 123.75) {
            dirStr = qsTr("ESE", "East South East")
        } else if (direction < 146.25) {
            dirStr = qsTr("SE", "South East")
        } else if (direction < 168.75) {
            dirStr = qsTr("SSE", "South South East")
        } else if (direction < 191.25) {
            dirStr = south
        } else if (direction < 213.75) {
            dirStr = qsTr("SSW", "South South West")
        } else if (direction < 236.25) {
            dirStr = qsTr("SW", "South West")
        } else if (direction < 258.75) {
            dirStr = qsTr("WSW", "West South West")
        } else if (direction < 281.25) {
            dirStr = west
        } else if (direction < 303.75) {
            dirStr = qsTr("WNW", "West North West")
        } else if (direction < 326.25) {
            dirStr = qsTr("NW", "Norh West")
        } else if (direction < 348.75) {
            dirStr = qsTr("NNW", "North North West")
        } else if (direction < 360) {
            dirStr = north
        } else {
            dirStr = "?"
        }
        return dirStr === "?" ? "-" : dirStr + " (" + roundToDecimal(direction, 0) + "°)"
    }
}
