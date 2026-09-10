import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property string title
    property string unit
    property var values: []
    property var values2: []
    property color lineColor: Theme.highlightColor
    property color lineColor2: Theme.secondaryHighlightColor

    onValuesChanged: canvas.requestPaint()
    onValues2Changed: canvas.requestPaint()

    height: titleLabel.height + Theme.itemSizeMedium

    Label {
        id: titleLabel
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.primaryColor
        text: root.title + (root.values.length > 0
                            ? "  " + root.values[root.values.length - 1].toFixed(1) + " " + root.unit
                            : "")
        truncationMode: TruncationMode.Fade
    }

    Canvas {
        id: canvas
        anchors {
            top: titleLabel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = Theme.rgba(Theme.secondaryColor, 0.4);
            ctx.lineWidth = 1;
            ctx.strokeRect(0, 0, width, height);

            var series = root.values;
            if (!series || series.length < 2)
                return;

            var all = series.slice();
            if (root.values2 && root.values2.length > 0)
                all = all.concat(root.values2);
            var max = Math.max.apply(null, all);
            var min = Math.min.apply(null, all);
            if (max === min)
                max = min + 1;

            function draw(data, color) {
                ctx.beginPath();
                ctx.strokeStyle = color;
                ctx.lineWidth = 2;
                for (var i = 0; i < data.length; i++) {
                    var x = i * width / (data.length - 1);
                    var y = height - (data[i] - min) / (max - min) * height;
                    if (i === 0)
                        ctx.moveTo(x, y);
                    else
                        ctx.lineTo(x, y);
                }
                ctx.stroke();
            }

            draw(series, root.lineColor);
            if (root.values2 && root.values2.length > 1)
                draw(root.values2, root.lineColor2);
        }
    }
}
