import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Effects

Item {
    id: root
    property var toplevels: []

    // Local order list - stores windows in custom order
    property var windowOrder: []

    // Drag state
    property var draggedItem: null
    property int dragStartIndex: -1
    property int dragTargetIndex: -1

    // Listen to model changes
    Connections {
        target: toplevels
        function onObjectInsertedPost() { updateWindowOrder() }
        function onObjectRemovedPost() { updateWindowOrder() }
    }

    Component.onCompleted: updateWindowOrder()

    function updateWindowOrder() {
        if (!toplevels || !toplevels.values) return

        let currentWindows = []
        for (let i = 0; i < toplevels.values.length; i++) {
            currentWindows.push(toplevels.values[i])
        }

        // Remove windows that no longer exist
        let newOrder = windowOrder.filter(w => currentWindows.includes(w))

        // Add new windows that aren't in order yet
        for (let i = 0; i < currentWindows.length; i++) {
            if (!newOrder.includes(currentWindows[i])) {
                newOrder.push(currentWindows[i])
            }
        }

        windowOrder = newOrder
    }

    function getIconName(appId) {
        const iconMap = {
            "code": "vscode",
        }
        return iconMap[appId] || appId
    }

    property string fallbackIcon: Quickshell.iconPath("application-x-executable-symbolic", false)

    function getIconPath(appId) {
        if (!appId) return fallbackIcon
        const iconName = getIconName(appId)
        const path = Quickshell.iconPath(iconName, true)
        console.log("path", path)
        return path !== "" ? path : fallbackIcon
    }

    width: taskRow.width
    height: parent.height

    // Drop indicator
    Rectangle {
        visible: root.dragTargetIndex >= 0 && root.draggedItem !== null
        x: root.dragTargetIndex * (160 + taskRow.spacing)
        y: 8
        width: 3
        height: parent.height - 16
        color: "#2596be"
        radius: 2
        z: 100
    }

    Row {
        id: taskRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 4

        Repeater {
            model: windowOrder

            Item {
                id: taskItem
                required property var modelData
                required property int index

                property real calculatedWidth: titleMetrics.width + 52
                width: Math.min(180, calculatedWidth)
                height: parent.height

                // Drag properties
                property bool isDragging: false
                property real dragStartX: 0

                TextMetrics {
                    id: titleMetrics
                    font.pixelSize: 13
                    text: modelData.title || "Window"
                }

                // Background rectangle with hover/active state
                Rectangle {
                    id: taskRect
                    anchors.centerIn: parent
                    width: parent.width - 4
                    height: 32
                    radius: 5
                    color: modelData.activated ? "#22ffffff" : (taskMouse.containsMouse ? "#18ffffff" : "transparent")
                    opacity: modelData.minimized ? 0.6 : 1.0
                    clip: true

                    // Visual feedback when dragging
                    border.width: taskItem.isDragging ? 2 : 0
                    border.color: "#2596be"

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        // Icon
                        Image {
                            id: appIcon
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            source: getIconPath(modelData.appId)
                            sourceSize: Qt.size(20, 20)
                            layer.enabled: source == fallbackIcon
                            layer.effect: MultiEffect {
                                colorization: 1.0
                                colorizationColor: "white"
                                brightness: 1.0
                            }
                        }

                        // Title
                        Text {
                            id: titleText
                            anchors.verticalCenter: parent.verticalCenter
                            width: taskItem.calculatedWidth > 180 ? parent.width - 28 : titleMetrics.width
                            text: modelData.title || "Window"
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            elide: taskItem.calculatedWidth > 180 ? Text.ElideRight : Text.ElideNone
                        }
                    }

                    // Active indicator (inside rectangle)
                    Rectangle {
                        x: appIcon.parent.x + appIcon.x + (appIcon.width - width) / 2
                        anchors.bottom: parent.bottom
                        width: modelData.activated ? 10 : (taskMouse.containsMouse ? 6 : 3)
                        height: 3
                        radius: 2
                        color: modelData.activated ? "#2596be" : "#6c7086"
                        visible: width > 0

                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }

                Menu {
                    id: contextMenu
                    popupType: Popup.Window

                    background: Rectangle {
                        implicitWidth: 160
                        color: "#1a1a1a"
                        border.color: "#2a2a2a"
                        border.width: 1
                        radius: 8
                    }

                    MenuItem {
                        text: modelData.minimized ? "Restore" : "Minimize"
                        onTriggered: modelData.minimized = !modelData.minimized
                        contentItem: Text {
                            text: parent.text
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#2a2a2a" : "transparent"
                            radius: 4
                        }
                    }

                    MenuItem {
                        text: "Close"
                        onTriggered: modelData.requestClose()
                        contentItem: Text {
                            text: parent.text
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#2a2a2a" : "transparent"
                            radius: 4
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitWidth: 140
                            implicitHeight: 1
                            color: "#2a2a2a"
                        }
                    }

                    MenuItem {
                        text: "Kill Process"
                        onTriggered: killProc.running = true
                        contentItem: Text {
                            text: parent.text
                            color: "#f38ba8"
                            font.pixelSize: 12
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#2a2a2a" : "transparent"
                            radius: 4
                        }
                    }

                    Process {
                        id: killProc
                        command: ["kill", "-9", String(modelData.pid)]
                    }
                }

                MouseArea {
                    id: taskMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                    property real pressX: 0
                    property bool potentialDrag: false

                    onPressed: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            pressX = mouse.x
                            potentialDrag = true
                        }
                    }

                    onPositionChanged: (mouse) => {
                        if (!potentialDrag) return

                        // Start dragging after 10px movement
                        if (!taskItem.isDragging && Math.abs(mouse.x - pressX) > 10) {
                            taskItem.isDragging = true
                            root.draggedItem = modelData
                            root.dragStartIndex = taskItem.index
                            root.dragTargetIndex = taskItem.index
                        }

                        if (taskItem.isDragging) {
                            let itemWidth = 160 + taskRow.spacing
                            let pos = mapToItem(taskRow, mouse.x, mouse.y)
                            let newIndex = Math.floor(pos.x / itemWidth)
                            root.dragTargetIndex = Math.max(0, Math.min(newIndex, windowOrder.length - 1))
                        }
                    }

                    onReleased: (mouse) => {
                        if (taskItem.isDragging && root.draggedItem) {
                            // Save values before resetting
                            let draggedWindow = root.draggedItem
                            let targetIdx = root.dragTargetIndex

                            // Reset drag state BEFORE modifying windowOrder
                            taskItem.isDragging = false
                            potentialDrag = false
                            root.draggedItem = null
                            root.dragStartIndex = -1
                            root.dragTargetIndex = -1

                            // Do reorder after reset
                            let currentIndex = windowOrder.indexOf(draggedWindow)
                            if (targetIdx !== currentIndex && currentIndex !== -1) {
                                let newOrder = [...windowOrder]
                                let item = newOrder.splice(currentIndex, 1)[0]
                                newOrder.splice(targetIdx, 0, item)
                                windowOrder = newOrder
                            }
                        } else if (mouse.button === Qt.LeftButton) {
                            if (modelData.activated) {
                                modelData.minimized = true
                            } else {
                                modelData.minimized = false
                                modelData.activate()
                            }
                            taskItem.isDragging = false
                            potentialDrag = false
                            root.draggedItem = null
                            root.dragStartIndex = -1
                            root.dragTargetIndex = -1
                        } else {
                            taskItem.isDragging = false
                            potentialDrag = false
                            root.draggedItem = null
                            root.dragStartIndex = -1
                            root.dragTargetIndex = -1
                        }
                    }

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.MiddleButton) {
                            modelData.requestClose()
                        } else if (mouse.button === Qt.RightButton) {
                            contextMenu.popup(taskItem, 0, -contextMenu.implicitHeight - 8)
                        }
                    }

                    onCanceled: {
                        taskItem.isDragging = false
                        potentialDrag = false
                        root.draggedItem = null
                        root.dragStartIndex = -1
                        root.dragTargetIndex = -1
                    }
                }
            }
        }
    }
}
