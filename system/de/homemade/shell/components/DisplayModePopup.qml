import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
    property bool popupVisible: false
    property string currentMode: "extend"
    property int focusedIndex: -1
    readonly property var modes: ["pc", "duplicate", "extend", "second"]

    function toggle() {
        if (popupVisible) {
            focusedIndex = (focusedIndex + 1) % modes.length
        } else {
            focusedIndex = modes.indexOf(currentMode)
            detectCurrentMode.running = true
            popupVisible = true
        }
    }

    // Detect current display mode via wlr-randr
    Process {
        id: detectCurrentMode
        command: ["sh", "-c", "wlr-randr | awk '/^[^ ]/{name=$1} /Enabled:/{en[name]=$2} /Position:/{pos[name]=$2} END{for(n in en) print n, en[n], pos[n]}'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.parseOutputLine(data)
            }
        }

        onExited: (code, status) => {
            root.resolveMode()
        }
    }

    property var outputStates: ({})
    property int parseCount: 0

    function parseOutputLine(line) {
        let parts = line.trim().split(/\s+/)
        if (parts.length >= 3) {
            outputStates[parts[0]] = {
                enabled: parts[1] === "yes",
                position: parts[2]
            }
            parseCount++
        }
    }

    function resolveMode() {
        let hdmi1 = outputStates["HDMI-A-1"]
        let hdmi2 = outputStates["HDMI-A-2"]
        if (!hdmi1 && !hdmi2) { currentMode = "extend"; outputStates = {}; parseCount = 0; return }

        if (hdmi1 && hdmi1.enabled && (!hdmi2 || !hdmi2.enabled)) {
            currentMode = "pc"
        } else if ((!hdmi1 || !hdmi1.enabled) && hdmi2 && hdmi2.enabled) {
            currentMode = "second"
        } else if (hdmi1 && hdmi2 && hdmi1.enabled && hdmi2.enabled) {
            if (hdmi1.position === hdmi2.position) {
                currentMode = "duplicate"
            } else {
                currentMode = "extend"
            }
        } else {
            currentMode = "extend"
        }
        outputStates = {}
        parseCount = 0
    }

    // Apply display mode
    Process {
        id: applyMode
        running: false
    }

    function applyDisplayMode(mode) {
        currentMode = mode
        let cmd = ""
        if (mode === "pc") {
            cmd = "wlr-randr --output HDMI-A-1 --pos 0,0 --mode 3840x2160@240Hz --on --output HDMI-A-2 --off"
        } else if (mode === "extend") {
            cmd = "wlr-randr --output HDMI-A-1 --pos 0,0 --mode 3840x2160@240Hz --on --output HDMI-A-2 --pos 3840,0 --on"
        } else if (mode === "duplicate") {
            cmd = "wlr-randr --output HDMI-A-1 --pos 0,0 --mode 3840x2160@240Hz --on --output HDMI-A-2 --pos 0,0 --on"
        } else if (mode === "second") {
            cmd = "wlr-randr --output HDMI-A-1 --off --output HDMI-A-2 --pos 0,0 --on"
        }
        applyMode.command = ["sh", "-c", cmd]
        applyMode.running = true
        closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: 600
        onTriggered: root.popupVisible = false
    }

    // Overlay: dim background, click to close
    PanelWindow {
        visible: root.popupVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "#66000000"

        WlrLayershell.namespace: "displaymode-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        MouseArea {
            anchors.fill: parent
            onClicked: root.popupVisible = false
        }
    }

    // Popup: centered content
    PanelWindow {
        id: popup
        visible: root.popupVisible

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        WlrLayershell.namespace: "displaymode-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        exclusiveZone: -1

        mask: Region { item: popupContainer }

        Item {
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.popupVisible = false
                } else if (event.key === Qt.Key_Left) {
                    root.focusedIndex = (root.focusedIndex - 1 + root.modes.length) % root.modes.length
                } else if (event.key === Qt.Key_Right) {
                    root.focusedIndex = (root.focusedIndex + 1) % root.modes.length
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (root.focusedIndex >= 0 && root.focusedIndex < root.modes.length) {
                        root.applyDisplayMode(root.modes[root.focusedIndex])
                    }
                }
                event.accepted = true
            }
        }

        // Centered popup container
        Rectangle {
            id: popupContainer
            anchors.centerIn: parent
            width: popupColumn.implicitWidth + 48
            height: popupColumn.implicitHeight + 28
            radius: 12
            color: "#ee1a1a1a"
            border.color: "#2a2a2a"
            border.width: 1

            Column {
                id: popupColumn
                anchors.centerIn: parent
                spacing: 12

                // Title
                Text {
                    text: "Project"
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    id: contentRow
                    spacing: 16

                // PC screen only
                DisplayModeButton {
                    label: "PC screen only"
                    mode: "pc"
                    selected: root.currentMode === "pc"
                    focused: root.focusedIndex === 0
                    onClicked: root.applyDisplayMode("pc")

                    iconContent: Component {
                        Item {
                            width: 80
                            height: 50
                            // Single monitor (left)
                            Rectangle {
                                x: 16; y: 5
                                width: 48; height: 30
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            // Stand
                            Rectangle {
                                x: 34; y: 35
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                            // Dim second monitor
                            Rectangle {
                                x: 48; y: 12
                                width: 24; height: 16
                                color: "transparent"
                                border.color: "#333333"
                                border.width: 1
                                radius: 1
                            }
                        }
                    }
                }

                // Duplicate
                DisplayModeButton {
                    label: "Duplicate"
                    mode: "duplicate"
                    selected: root.currentMode === "duplicate"
                    focused: root.focusedIndex === 1
                    onClicked: root.applyDisplayMode("duplicate")

                    iconContent: Component {
                        Item {
                            width: 80
                            height: 50
                            // Two monitors overlapping
                            Rectangle {
                                x: 12; y: 5
                                width: 36; height: 24
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            Rectangle {
                                x: 32; y: 5
                                width: 36; height: 24
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            // Stands
                            Rectangle {
                                x: 24; y: 29
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                            Rectangle {
                                x: 44; y: 29
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                        }
                    }
                }

                // Extend
                DisplayModeButton {
                    label: "Extend"
                    mode: "extend"
                    selected: root.currentMode === "extend"
                    focused: root.focusedIndex === 2
                    onClicked: root.applyDisplayMode("extend")

                    iconContent: Component {
                        Item {
                            width: 80
                            height: 50
                            // Two monitors side by side
                            Rectangle {
                                x: 4; y: 5
                                width: 34; height: 24
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            Rectangle {
                                x: 42; y: 5
                                width: 34; height: 24
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            // Stands
                            Rectangle {
                                x: 15; y: 29
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                            Rectangle {
                                x: 53; y: 29
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                        }
                    }
                }

                // Second screen only
                DisplayModeButton {
                    label: "Second screen only"
                    mode: "second"
                    selected: root.currentMode === "second"
                    focused: root.focusedIndex === 3
                    onClicked: root.applyDisplayMode("second")

                    iconContent: Component {
                        Item {
                            width: 80
                            height: 50
                            // Dim first monitor
                            Rectangle {
                                x: 8; y: 12
                                width: 24; height: 16
                                color: "transparent"
                                border.color: "#333333"
                                border.width: 1
                                radius: 1
                            }
                            // Single monitor (right)
                            Rectangle {
                                x: 16; y: 5
                                width: 48; height: 30
                                color: "transparent"
                                border.color: "#cdd6f4"
                                border.width: 2
                                radius: 2
                            }
                            // Stand
                            Rectangle {
                                x: 34; y: 35
                                width: 12; height: 4
                                color: "#cdd6f4"
                            }
                        }
                    }
                }
            }
        }
    }
    }

    // Reusable button component
    component DisplayModeButton: Rectangle {
        id: btn
        property string label
        property string mode
        property bool selected: false
        property bool focused: false
        property Component iconContent
        signal clicked()

        width: 110
        height: 100
        radius: 8
        color: selected ? "#2a2a2a" : (focused || btnMouse.containsMouse ? "#222222" : "transparent")
        border.color: selected ? "#2596be" : (focused ? "#cdd6f4" : (btnMouse.containsMouse ? "#333333" : "#2a2a2a"))
        border.width: selected || focused ? 2 : 1

        Column {
            anchors.centerIn: parent
            spacing: 8

            // Icon area
            Loader {
                sourceComponent: btn.iconContent
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Label
            Text {
                text: btn.label
                color: btn.selected ? "#2596be" : "#cdd6f4"
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }
}

