//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt.labs.platform
import "components"

ShellRoot {
    id: root

    property var primaryScreen: _findPrimaryScreen()

    function _findPrimaryScreen() {
        for (const screen of Quickshell.screens) {
            if (screen.name === "HDMI-A-1") {
                return screen
            }
        }
        return Quickshell.screens[0] ?? null
    }

    Connections {
        target: Quickshell.screens
        function onObjectInsertedPost() { root.primaryScreen = root._findPrimaryScreen() }
        function onObjectRemovedPost() { root.primaryScreen = root._findPrimaryScreen() }
    }

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

    AppLauncher { id: appLauncher; screen: root.primaryScreen }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            appLauncher.toggle()
        }

        function close(): void {
            appLauncher.close()
        }
    }

    IpcHandler {
        target: "displayMode"

        function toggle(): void {
            displayModePopup.toggle()
        }
    }

    NotificationPopup { id: notifPopup }
    VolumeOsd {}
    DisplayModePopup { id: displayModePopup }

    PanelWindow {
        id: bar
        screen: root.primaryScreen
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: 44
        color: "#141414"

        WlrLayershell.namespace: "taskbar"
        WlrLayershell.layer: appLauncher.popupVisible ? WlrLayer.Overlay : WlrLayer.Top

        exclusiveZone: implicitHeight

        // Left section - Start + TaskBar
        Row {
            id: leftSection
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 0

            StartButton { appLauncher: appLauncher; leftPadding: 4 }
            TaskBar { toplevels: ToplevelManager.toplevels }
        }

        // Right section - System tray, volume, clock, etc.
        Row {
            id: rightSection
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 2

            // FpsCounter {}
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
