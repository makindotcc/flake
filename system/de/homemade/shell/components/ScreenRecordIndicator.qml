import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    property bool recording: false
    property string recordingApp: ""

    width: recording ? 28 : 0
    height: parent.height
    visible: recording

    Behavior on width {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    Rectangle {
        id: dotBg
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 12
        color: indicatorMouse.containsMouse ? "#55ff4444" : "#33ff4444"

        // Pulsing red dot
        Rectangle {
            id: dot
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 5
            color: "#ff4444"

            SequentialAnimation on opacity {
                running: recording
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
        }
    }

    MouseArea {
        id: indicatorMouse
        anchors.fill: parent
        hoverEnabled: true
    }

    ToolTip {
        visible: indicatorMouse.containsMouse && recording
        text: "Screen recording: " + (recordingApp || "unknown")
        popupType: Popup.Window
        delay: 0
        y: -height - 8

        contentItem: Row {
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                radius: 4
                color: "#ff4444"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Screen recording: " + (root.recordingApp || "unknown")
                color: "#cdd6f4"
                font.pixelSize: 12
            }
        }

        background: Rectangle {
            color: "#1a1a1a"
            radius: 6
            border.color: "#2a2a2a"
            border.width: 1
        }
    }

    Process {
        id: checkProc
        command: ["sh", "-c", "pw-link -ol 2>/dev/null | grep -A1 'portal.*capture' | grep '|->' | sed 's/.*|-> //' | sed 's/:.*//; s/^\\.//' | sort -u | paste -sd ', '"]
        stdout: SplitParser {
            onRead: data => {
                let result = data.trim()
                if (result.length > 0) {
                    root.recording = true
                    root.recordingApp = result
                } else {
                    root.recording = false
                    root.recordingApp = ""
                }
            }
        }
    }

    // Fallback: if process returns nothing, mark as not recording
    Process {
        id: checkEmpty
        command: ["sh", "-c", "pw-link -ol 2>/dev/null | grep -q 'portal.*capture' && echo yes || echo no"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "no") {
                    root.recording = false
                    root.recordingApp = ""
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkProc.running = true
            checkEmpty.running = true
        }
    }
}
