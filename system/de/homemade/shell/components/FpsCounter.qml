import QtQuick

Item {
    width: fpsText.width + 8
    height: parent.height

    property real displayFps: 0

    FrameAnimation {
        id: frameAnimation
        running: true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: displayFps = frameAnimation.smoothFrameTime > 0 ? (1.0 / frameAnimation.smoothFrameTime) : 0
    }

    Text {
        id: fpsText
        anchors.verticalCenter: parent.verticalCenter
        text: displayFps.toFixed(0) + " fps"
        color: displayFps >= 55 ? "#a6e3a1" : displayFps >= 30 ? "#f9e2af" : "#f38ba8"
        font.pixelSize: 11
        font.family: "monospace"
    }
}
