import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects

Item {
    property var toplevels: []
    property int extraVerticalPadding: 4

    function getIconName(appId) {
        const iconMap = {
            "code": "vscode",
            "code-url-handler": "vscode",
            "Code": "vscode",
            "chromium-browser": "chromium",
            "google-chrome": "chrome",
            "org.gnome.Nautilus": "nautilus"
        }
        return iconMap[appId] || appId
    }

    property string fallbackIcon: Quickshell.iconPath("application-x-executable-symbolic", false)

    function getIconPath(appId) {
        if (!appId) return fallbackIcon
        const iconName = getIconName(appId)
        const path = Quickshell.iconPath(iconName, true)
        return path !== "" ? path : fallbackIcon
    }

    Layout.fillWidth: true
    Layout.fillHeight: true

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 2

        Repeater {
            model: toplevels

            Item {
                required property var modelData

                width: 180
                height: parent.height

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: parent.height - (extraVerticalPadding * 2)
                    color: modelData.activated ? "#45475a" : (taskMouse.containsMouse ? "#313244" : "transparent")
                    opacity: modelData.minimized ? 0.6 : 1.0
                    radius: 4

                    Row {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Rectangle {
                            width: 20
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                source: getIconPath(modelData.appId)
                                sourceSize: Qt.size(20, 20)
                                layer.enabled: source == fallbackIcon
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: "white"
                                    brightness: 1.0
                                }
                            }
                        }

                        Text {
                            width: parent.width - 26
                            height: parent.height
                            text: modelData.title || "Window"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                MouseArea {
                    id: taskMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (modelData.activated) {
                                modelData.minimized = true
                            } else {
                                modelData.minimized = false
                                modelData.activate()
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            modelData.requestClose()
                        }
                    }
                }
            }
        }
    }
}
