import QtQuick
import QtQuick.Layouts

Item {
    property int extraVerticalPadding: 4

    Layout.fillWidth: false
    Layout.fillHeight: true
    Layout.preferredWidth: clockText.implicitWidth + 16

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: extraVerticalPadding
        anchors.bottomMargin: extraVerticalPadding
        color: clockMouse.containsMouse ? "#313244" : "transparent"
        radius: 4

        Text {
            id: clockText
            anchors.centerIn: parent
            color: "#cdd6f4"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    clockText.text = now.toLocaleTimeString(Qt.locale(), "hh:mm") + "\n" + now.toLocaleDateString(Qt.locale(), "dd.MM")
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
