import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }

        function onMutedChanged() {
            root.shouldShowOsd = true
            hideTimer.restart()
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            screen: Quickshell.screens.find(s => s.name === "HDMI-A-2") ?? Quickshell.screens[0]

            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 300
            implicitHeight: 44
            color: "transparent"

            WlrLayershell.namespace: "volume-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#ee1a1a1a"
                border.color: "#2a2a2a"
                border.width: 1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 10

                    Text {
                        text: {
                            const muted = Pipewire.defaultAudioSink?.audio?.muted ?? false
                            const vol = Pipewire.defaultAudioSink?.audio?.volume ?? 0
                            if (muted) return "󰖁"
                            if (vol > 0.5) return "󰕾"
                            if (vol > 0) return "󰖀"
                            return "󰕿"
                        }
                        color: (Pipewire.defaultAudioSink?.audio?.muted ?? false) ? "#6c7086" : "#cdd6f4"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 8
                        radius: 4
                        color: "#2a2a2a"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width: parent.width * Math.min(1, Pipewire.defaultAudioSink?.audio?.volume ?? 0)
                            radius: parent.radius
                            color: (Pipewire.defaultAudioSink?.audio?.muted ?? false) ? "#6c7086" : "#2596be"

                            Behavior on width {
                                NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Text {
                        text: Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100) + "%"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
