import QtQuick
import QtQuick.Layouts

Item {
    property int extraVerticalPadding: 4

    Layout.fillWidth: false
    Layout.fillHeight: true
    Layout.preferredWidth: maxWidthMetrics.width + 16

    TextMetrics {
        id: maxWidthMetrics
        font: clockText.font
        text: "00:00:00"
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: extraVerticalPadding
        anchors.bottomMargin: extraVerticalPadding
        color: clockMouse.containsMouse ? "#313244" : "transparent"
        radius: 4

        Text {
            id: clockText
            anchors.centerIn: parent
            width: maxWidthMetrics.width
            color: "#cdd6f4"
            font.pixelSize: 12
            font.family: "monospace"
            horizontalAlignment: Text.AlignHCenter

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    clockText.text = now.toLocaleTimeString(Qt.locale(), "hh:mm:ss") + "\n" + now.toLocaleDateString(Qt.locale(), "dd.MM")
                }
            }
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
