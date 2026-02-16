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

    IpcHandler {
        target: "displayMode"

        function toggle(): void {
            displayModePopup.toggle()
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

    NotificationPopup { id: notifPopup }
    VolumeOsd {}
    DisplayModePopup { id: displayModePopup }

    PanelWindow {
        id: bar
        screen: Quickshell.screens.find(s => s.name === "HDMI-A-2") ?? Quickshell.screens[0]
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: 44
        color: "#141414"

        WlrLayershell.namespace: "taskbar"
        WlrLayershell.layer: WlrLayer.Top

        exclusiveZone: implicitHeight

        // Left section - Start + TaskBar
        Row {
            id: leftSection
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 0

            StartButton { fuzzelProc: fuzzelProc; leftPadding: 4 }
            TaskBar { toplevels: ToplevelManager.toplevels }
        }

        // Right section - System tray, volume, clock, etc.
        Row {
            id: rightSection
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 2

            ScreenRecordIndicator {}
            SystemTray { id: systemTray }
            VolumeControl {}
            BluetoothStatus {}
            NotificationCenter { notifPopup: notifPopup }
            Clock {}
            ShowDesktopButton { toplevels: ToplevelManager.toplevels; rightPadding: 4 }
        }
    }
}
