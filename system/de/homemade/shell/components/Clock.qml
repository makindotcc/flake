import QtQuick
import QtQuick.Layouts

Item {
    width: clockColumn.width + 20
    height: parent.height

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: 32
        color: clockMouse.containsMouse ? "#33ffffff" : "transparent"
        radius: 5

        Column {
            id: clockColumn
            anchors.centerIn: parent
            spacing: 0

            TextMetrics {
                id: clockMetrics
                font: timeText.font
                text: "hh:mm:ss"
            }

            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#cdd6f4"
                font.pixelSize: 12
                // font.family: "SFMono Nerd Font"
                font.family: "monospace"
                width: clockMetrics.width
            }

            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#a6adc8"
                font.pixelSize: 10
                // font.family: "JetBrains Mono"
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    timeText.text = now.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
                    dateText.text = now.toLocaleDateString(Qt.locale(), "dd.MM.yyyy")
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
