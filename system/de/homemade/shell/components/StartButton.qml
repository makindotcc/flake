import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    property var fuzzelProc
    property bool powerMenuVisible: false
    property int leftPadding: 0

    width: 40 + leftPadding
    height: parent.height

    // Power commands
    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }
    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }
    Process {
        id: hibernateProc
        command: ["systemctl", "hibernate"]
    }
    Process {
        id: logoutProc
        command: ["labwc", "--exit"]
    }
    Process {
        id: lockProc
        command: ["swaylock"]
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: leftPadding + 2
        width: 36
        height: 32
        color: startMouse.containsMouse || powerMenuVisible ? "#33ffffff" : "transparent"
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (fuzzelProc.running) {
                    fuzzelProc.signal(15)
                } else {
                    fuzzelProc.running = true
                }
            } else if (mouse.button === Qt.RightButton) {
                powerMenuVisible = !powerMenuVisible
            }
        }
    }

    // Overlay to close menu
    PanelWindow {
        visible: powerMenuVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "power-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenuVisible = false
        }
    }

    // Power menu popup
    PanelWindow {
        id: powerMenu
        visible: powerMenuVisible

        anchors {
            bottom: true
            left: true
        }

        implicitWidth: 160
        implicitHeight: powerColumn.implicitHeight + 24

        WlrLayershell.namespace: "power-menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0

        color: "#1a1a1a"

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: powerColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            Text {
                text: "Power"
                color: "#cdd6f4"
                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#2a2a2a"
            }

            // Lock
            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: lockMouse.containsMouse ? "#222222" : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: "󰌾"
                        color: "#2596be"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Lock"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: lockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        powerMenuVisible = false
                        lockProc.running = true
                    }
                }
            }

            // Hibernate
            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: hibernateMouse.containsMouse ? "#222222" : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: "󰤄"
                        color: "#f9e2af"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Hibernate"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: hibernateMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        powerMenuVisible = false
                        hibernateProc.running = true
                    }
                }
            }

            // Restart
            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: rebootMouse.containsMouse ? "#222222" : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: "󰜉"
                        color: "#94e2d5"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Restart"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        powerMenuVisible = false
                        rebootProc.running = true
                    }
                }
            }

            // Logout
            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: logoutMouse.containsMouse ? "#222222" : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: "󰍃"
                        color: "#cba6f7"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Logout"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: logoutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        powerMenuVisible = false
                        logoutProc.running = true
                    }
                }
            }

            // Shutdown
            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: shutdownMouse.containsMouse ? "#222222" : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: "󰐥"
                        color: "#f38ba8"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Shutdown"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        powerMenuVisible = false
                        shutdownProc.running = true
                    }
                }
            }
        }
    }
}
