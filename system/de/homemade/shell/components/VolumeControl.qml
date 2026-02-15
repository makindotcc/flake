import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root
    property bool popupVisible: false

    width: 36
    height: parent.height

    // Bind the pipewire node so its properties will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    // Get all audio sinks (hardware outputs)
    property var allSinks: {
        let sinks = []
        if (Pipewire.nodes?.values) {
            for (let i = 0; i < Pipewire.nodes.values.length; i++) {
                let node = Pipewire.nodes.values[i]
                if (node.isSink && !node.isStream) {
                    sinks.push(node)
                }
            }
        }
        return sinks
    }

    Rectangle {
        anchors.centerIn: parent
        width: 32
        height: 32
        color: volumeMouse.containsMouse || popupVisible ? "#33ffffff" : "transparent"
        radius: 5

        Text {
            anchors.centerIn: parent
            text: muted ? "󰖁" : (volume > 0.5 ? "󰕾" : (volume > 0 ? "󰖀" : "󰕿"))
            color: muted ? "#6c7086" : "#cdd6f4"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
        }
    }

    MouseArea {
        id: volumeMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                popupVisible = !popupVisible
            } else if (mouse.button === Qt.RightButton && sink?.audio) {
                sink.audio.muted = !sink.audio.muted
            }
        }

        onWheel: (wheel) => {
            if (sink?.audio) {
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta))
            }
        }
    }

    // Overlay to close popup when clicking outside (lower layer)
    PanelWindow {
        visible: popupVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "volume-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        MouseArea {
            anchors.fill: parent
            onClicked: popupVisible = false
        }
    }

    // Popup panel for output selection (higher layer)
    PanelWindow {
        id: outputPopup
        visible: popupVisible

        anchors {
            bottom: true
            right: true
        }

        implicitWidth: 280
        implicitHeight: 280

        WlrLayershell.namespace: "volume-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0

        color: "#1a1a1a"

        // Prevent clicks from reaching overlay
        MouseArea {
            anchors.fill: parent
            onClicked: {} // eat the click
        }

        Column {
            id: sinkList
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Audio Output"
                color: "#cdd6f4"
                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#2a2a2a"
            }

            Repeater {
                model: allSinks

                Rectangle {
                    required property var modelData
                    width: sinkList.width - 24
                    height: 36
                    radius: 6
                    color: modelData === Pipewire.defaultAudioSink ? "#2a2a2a" : (sinkItemMouse.containsMouse ? "#222222" : "transparent")

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: modelData === Pipewire.defaultAudioSink ? "󰗠" : "󰝟"
                            color: modelData === Pipewire.defaultAudioSink ? "#a6e3a1" : "#6c7086"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.description || modelData.name || "Unknown"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            width: parent.width - 40
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: sinkItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Pipewire.preferredDefaultAudioSink = modelData
                            popupVisible = false
                        }
                    }
                }
            }

            // Volume slider section
            Rectangle {
                width: parent.width
                height: 1
                color: "#2a2a2a"
            }

            Text {
                text: "Volume"
                color: "#a6adc8"
                font.pixelSize: 11
            }

            Row {
                width: parent.width - 24
                height: 32
                spacing: 12

                Text {
                    text: muted ? "󰖁" : "󰕾"
                    color: muted ? "#6c7086" : "#cdd6f4"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (sink?.audio) sink.audio.muted = !sink.audio.muted
                        }
                    }
                }

                Rectangle {
                    width: parent.width - 80
                    height: 8
                    radius: 4
                    color: "#2a2a2a"
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * Math.min(1, volume)
                        height: parent.height
                        radius: parent.radius
                        color: muted ? "#6c7086" : "#2596be"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (mouse) => {
                            if (sink?.audio) {
                                sink.audio.volume = mouse.x / parent.width
                            }
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed && sink?.audio) {
                                sink.audio.volume = Math.max(0, Math.min(1.5, mouse.x / parent.width))
                            }
                        }
                    }
                }

                Text {
                    text: Math.round(volume * 100) + "%"
                    color: "#cdd6f4"
                    font.pixelSize: 12
                    width: 40
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
