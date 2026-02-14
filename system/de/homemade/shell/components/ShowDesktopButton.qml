import QtQuick
import QtQuick.Layouts

Item {
    property var toplevels
    property bool desktopShown: false
    property int extraRightPadding: 4
    property int extraVerticalPadding: 4

    Layout.preferredWidth: 6 + extraRightPadding
    Layout.fillHeight: true

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: extraRightPadding
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: parent.height - (extraVerticalPadding * 2)
        color: showDesktopMouse.containsMouse ? "#45475a" : "#313244"
        radius: 2
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
