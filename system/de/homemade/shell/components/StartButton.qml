import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    property var fuzzelProc
    property int extraLeftPadding: 4
    property int extraVerticalPadding: 4

    Layout.preferredWidth: 40 + extraLeftPadding
    Layout.fillHeight: true

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: extraLeftPadding
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: parent.height - (extraVerticalPadding * 2)
        color: startMouse.containsMouse ? "#45475a" : "transparent"
        radius: 4

        Text {
            anchors.centerIn: parent
            text: "⊞"
            color: "#89b4fa"
            font.pixelSize: 18
        }
    }

    MouseArea {
        id: startMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (fuzzelProc.running) {
                fuzzelProc.signal(15)
            } else {
                fuzzelProc.running = true
            }
        }
    }
}
