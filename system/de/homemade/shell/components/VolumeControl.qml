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

    // Track streams connected to the default sink
    PwNodeLinkTracker {
        id: linkTracker
        node: Pipewire.defaultAudioSink
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

    // Popup panel for output selection (higher layer) — full height to avoid compositor resize lag
    PanelWindow {
        id: outputPopup
        visible: popupVisible

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth: 300

        WlrLayershell.namespace: "volume-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0
        color: "transparent"

        // Only the popup area accepts input, rest is click-through to the overlay below
        mask: Region { item: popupBg }

        Rectangle {
            id: popupBg
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.min(popupContent.implicitHeight + 24, 500)
            color: "#1a1a1a"

            // Prevent clicks from reaching overlay
            MouseArea {
                anchors.fill: parent
                onClicked: {} // eat the click
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 12
                contentHeight: popupContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: popupContent
                    width: parent.width
                    spacing: 8

                // --- Audio Output section ---
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
                        width: popupContent.width
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

                // --- Volume slider section ---
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

                RowLayout {
                    width: parent.width
                    height: 32
                    spacing: 12

                    Text {
                        text: muted ? "󰖁" : "󰕾"
                        color: muted ? "#6c7086" : "#cdd6f4"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (sink?.audio) sink.audio.muted = !sink.audio.muted
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 24
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: volSliderTrack
                            anchors.centerIn: parent
                            width: parent.width
                            height: 8
                            radius: 4
                            color: "#2a2a2a"

                            Rectangle {
                                width: parent.width * Math.min(1, volume)
                                height: parent.height
                                radius: parent.radius
                                color: muted ? "#6c7086" : "#2596be"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: (mouse) => {
                                if (sink?.audio) {
                                    sink.audio.volume = mouse.x / width
                                }
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed && sink?.audio) {
                                    sink.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width))
                                }
                            }
                        }
                    }

                    Text {
                        text: Math.round(volume * 100) + "%"
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // --- Mixer section (per-app streams) ---
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#2a2a2a"
                    visible: linkTracker.linkGroups.length > 0
                }

                Text {
                    text: "Mixer"
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                    visible: linkTracker.linkGroups.length > 0
                }

                Repeater {
                    model: linkTracker.linkGroups

                    Rectangle {
                        required property PwLinkGroup modelData
                        property var streamNode: modelData.source
                        property bool streamReady: streamNode?.audio !== undefined && streamNode?.audio !== null

                        PwObjectTracker { objects: [streamNode] }

                        width: popupContent.width
                        height: streamCol.implicitHeight + 16
                        radius: 6
                        color: "#222222"

                        Column {
                            id: streamCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            // App name row with icon and mute button
                            Row {
                                width: parent.width
                                spacing: 8

                                Image {
                                    id: appIcon
                                    visible: source.toString() !== ""
                                    source: {
                                        const icon = streamNode?.properties?.["application.icon-name"] ?? "";
                                        return icon !== "" ? `image://icon/${icon}` : "";
                                    }
                                    sourceSize.width: 18
                                    sourceSize.height: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: {
                                        if (!streamNode) return "Unknown";
                                        const app = streamNode.properties?.["application.name"] ?? (streamNode.description !== "" ? streamNode.description : streamNode.name);
                                        const media = streamNode.properties?.["media.name"];
                                        return media !== undefined ? `${app} - ${media}` : (app || "Unknown");
                                    }
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width - (appIcon.visible ? 26 : 0) - 28
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Mute toggle
                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 4
                                    color: streamMuteMouse.containsMouse ? "#333333" : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: (streamReady && streamNode.audio.muted) ? "󰖁" : "󰕾"
                                        color: (streamReady && streamNode.audio.muted) ? "#6c7086" : "#a6adc8"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: streamMuteMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (streamReady) streamNode.audio.muted = !streamNode.audio.muted
                                        }
                                    }
                                }
                            }

                            // Volume slider row
                            RowLayout {
                                width: parent.width
                                height: 24
                                spacing: 8

                                Item {
                                    Layout.fillWidth: true
                                    height: 20
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: "#2a2a2a"

                                        Rectangle {
                                            width: parent.width * Math.min(1, streamReady ? streamNode.audio.volume : 0)
                                            height: parent.height
                                            radius: parent.radius
                                            color: (streamReady && streamNode.audio.muted) ? "#6c7086" : "#2596be"
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onPressed: (mouse) => {
                                            if (streamReady) {
                                                streamNode.audio.volume = mouse.x / width
                                            }
                                        }
                                        onPositionChanged: (mouse) => {
                                            if (pressed && streamReady) {
                                                streamNode.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width))
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: streamReady ? Math.round(streamNode.audio.volume * 100) + "%" : "0%"
                                    color: "#a6adc8"
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 25
                                    horizontalAlignment: Text.AlignRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
        }
    }
}

