//@ pragma UseQApplication
//@ pragma IconTheme Adwaita

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt.labs.platform
import "components"

ShellRoot {
    id: root

    property alias fuzzelProc: fuzzelProc

    // Wallpaper for each screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            color: "#000000"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "wallpaper"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusiveZone: -1

            // Empty mask = clicks pass through to labwc
            mask: Region {}

            Image {
                id: wallpaperImage
                anchors.fill: parent
                source: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/wallpaper.png"
                fillMode: Image.PreserveAspectCrop
            }
        }
    }

    Process {
        id: fuzzelProc
        command: ["fuzzel"]
    }

    IpcHandler {
        target: "fuzzel"

        function toggle(): void {
            if (fuzzelProc.running) {
                fuzzelProc.signal(15)
            } else {
                fuzzelProc.running = true
            }
        }

        function close(): void {
            fuzzelProc.signal(15)
        }
    }

    // Overlay to catch clicks outside fuzzel
    PanelWindow {
        id: overlay
        visible: fuzzelProc.running
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "fuzzel-overlay"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked: fuzzelProc.signal(15)
        }
    }

    PanelWindow {
        id: bar
        screen: Quickshell.screens.find(s => s.name === "HDMI-A-2") ?? Quickshell.screens[0]
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: 40
        color: "#1e1e2e"

        WlrLayershell.namespace: "taskbar"
        WlrLayershell.layer: WlrLayer.Top

        exclusiveZone: implicitHeight

        RowLayout {
            anchors.fill: parent
            spacing: 4

            StartButton { fuzzelProc: fuzzelProc }
            TaskBar { toplevels: ToplevelManager.toplevels }
            SystemTray { id: systemTray }
            VolumeControl {}
            BluetoothStatus {}
            Clock {}
            ShowDesktopButton { toplevels: ToplevelManager.toplevels }
        }
    }
}
