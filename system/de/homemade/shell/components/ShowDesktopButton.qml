import QtQuick
import QtQuick.Layouts

Item {
    property var toplevels
    property bool desktopShown: false
    property int rightPadding: 0

    width: 8 + rightPadding
    height: parent.height

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: rightPadding + 2
        anchors.verticalCenter: parent.verticalCenter
        width: 4
        height: 24
        color: showDesktopMouse.containsMouse ? "#2596be" : "#2a2a2a"
        radius: 2

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: showDesktopMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            var values = toplevels.values
            for (var i = 0; i < values.length; i++) {
                values[i].minimized = !desktopShown
            }
            desktopShown = !desktopShown
        }
    }
}
