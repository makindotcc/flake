import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Item {
    id: root
    property int extraVerticalPadding: 4

    Layout.preferredWidth: trayRow.width
    Layout.fillHeight: true

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: SystemTray.items

            Rectangle {
                required property var modelData
                width: 28
                height: root.parent.height - (extraVerticalPadding * 2)
                radius: 4
                color: trayItemMouse.containsMouse ? "#45475a" : "transparent"

                IconImage {
                    anchors.centerIn: parent
                    source: modelData.icon
                    implicitSize: 18
                }

                MouseArea {
                    id: trayItemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (modelData.onlyMenu && modelData.hasMenu) {
                                menuAnchor.open()
                            } else {
                                modelData.activate()
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            modelData.secondaryActivate()
                        } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            menuAnchor.open()
                        }
                    }
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: modelData.menu
                    anchor.item: parent
                    anchor.edges: Edges.Top
                    anchor.gravity: Edges.Top
                }
            }
        }
    }
}
