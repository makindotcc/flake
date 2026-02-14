import QtQuick
import QtQuick.Layouts

Item {
    property int extraVerticalPadding: 8

    Layout.preferredWidth: 1
    Layout.fillHeight: true

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: parent.height - (extraVerticalPadding * 2)
        color: "#45475a"
    }
}


