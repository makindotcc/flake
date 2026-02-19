import QtQuick
import Quickshell

Item {
    property var appLauncher
    property int leftPadding: 0

    width: 40 + leftPadding
    height: parent.height

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: leftPadding + 2
        width: 36
        height: 32
        color: startMouse.containsMouse || (appLauncher && appLauncher.popupVisible) ? "#33ffffff" : "transparent"
        radius: 5

        // Windows 11 style logo (4 squares)
        Grid {
            anchors.centerIn: parent
            columns: 2
            spacing: 2

            Repeater {
                model: 4
                Rectangle {
                    width: 8
                    height: 8
                    radius: 2
                    color: "#2596be"
                }
            }
        }
    }

    MouseArea {
        id: startMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: appLauncher.toggle()
    }
}
