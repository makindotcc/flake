import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth

Item {
    id: root
    property int extraVerticalPadding: 4
    property bool popupVisible: false

    Layout.preferredWidth: 30
    Layout.fillHeight: true

    // Direct binding to adapter powered state
    property bool powered: Bluetooth.defaultAdapter?.enabled ?? false

    property var allDevices: {
        let devices = []
        if (Bluetooth.devices?.values) {
            for (let i = 0; i < Bluetooth.devices.values.length; i++) {
                devices.push(Bluetooth.devices.values[i])
            }
        }
        return devices
    }

    property int connectedCount: {
        let count = 0
        for (let i = 0; i < allDevices.length; i++) {
            if (allDevices[i].connected) count++
        }
        return count
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: parent.height - (extraVerticalPadding * 2)
        color: btMouse.containsMouse || popupVisible ? "#45475a" : "transparent"
        radius: 4

        Text {
            anchors.centerIn: parent
            text: powered ? (connectedCount > 0 ? "󰂱" : "󰂯") : "󰂲"
            color: powered ? (connectedCount > 0 ? "#a6e3a1" : "#89b4fa") : "#6c7086"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
        }

        Text {
            visible: connectedCount > 0
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 2
            text: connectedCount.toString()
            color: "#a6e3a1"
            font.pixelSize: 9
        }
    }

    MouseArea {
        id: btMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                popupVisible = !popupVisible
            } else if (mouse.button === Qt.RightButton) {
                if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.powered = !Bluetooth.defaultAdapter.powered
            }
        }
    }

    // Overlay to close popup when clicking outside
    PanelWindow {
        visible: popupVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "bt-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            onClicked: popupVisible = false
        }
    }

    // Popup panel for bluetooth devices
    PanelWindow {
        id: btPopup
        visible: popupVisible

        anchors {
            bottom: true
            right: true
        }

        implicitWidth: 300
        implicitHeight: Math.min(deviceList.implicitHeight + 24, 400)

        WlrLayershell.namespace: "bt-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0

        color: "#1e1e2e"

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: deviceList
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Header with power toggle
            Row {
                width: parent.width
                height: 30
                spacing: 10

                Text {
                    text: "Bluetooth"
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { Layout.fillWidth: true; width: parent.width - 150 }

                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: powered ? "#89b4fa" : "#45475a"
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: "#cdd6f4"
                        anchors.verticalCenter: parent.verticalCenter
                        x: powered ? parent.width - width - 2 : 2

                        Behavior on x {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.powered = !Bluetooth.defaultAdapter.powered
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#45475a"
            }

            // Status text
            Text {
                visible: !powered
                text: "Bluetooth is off"
                color: "#6c7086"
                font.pixelSize: 12
            }

            Text {
                visible: powered && allDevices.length === 0
                text: "No devices paired"
                color: "#6c7086"
                font.pixelSize: 12
            }

            // Device list
            Repeater {
                model: powered ? allDevices : []

                Rectangle {
                    id: deviceItem
                    required property var modelData
                    width: deviceList.width - 24
                    height: 44
                    radius: 6
                    color: deviceItemMouse.containsMouse ? "#313244" : "transparent"

                    property bool isConnecting: modelData.state === BluetoothDeviceState.Connecting
                    property bool isDisconnecting: modelData.state === BluetoothDeviceState.Disconnecting
                    property bool isBusy: isConnecting || isDisconnecting

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            id: deviceIcon
                            text: deviceItem.isBusy ? "󰁪" : (deviceItem.modelData.connected ? "󰂱" : "󰂯")
                            color: deviceItem.isBusy ? "#f9e2af" : (deviceItem.modelData.connected ? "#a6e3a1" : "#6c7086")
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter

                            NumberAnimation on rotation {
                                running: deviceItem.isBusy
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                onRunningChanged: if (!running) deviceIcon.rotation = 0
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: deviceItem.modelData.name || "Unknown Device"
                                color: "#cdd6f4"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                width: deviceList.width - 100
                            }

                            Text {
                                text: {
                                    if (deviceItem.isConnecting) return "Connecting..."
                                    if (deviceItem.isDisconnecting) return "Disconnecting..."
                                    return deviceItem.modelData.connected ? "Connected" : "Paired"
                                }
                                color: deviceItem.isBusy ? "#f9e2af" : (deviceItem.modelData.connected ? "#a6e3a1" : "#6c7086")
                                font.pixelSize: 10
                            }
                        }
                    }

                    MouseArea {
                        id: deviceItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !deviceItem.isBusy
                        onClicked: {
                            modelData.connected = !modelData.connected
                        }
                    }
                }
            }
        }
    }
}
