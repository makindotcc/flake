import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Effects

Item {
    id: root
    property var toplevels: []
    property int extraVerticalPadding: 4

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
            "code-url-handler": "vscode",
            "Code": "vscode",
            "chromium-browser": "chromium",
            "google-chrome": "chrome",
            "org.gnome.Nautilus": "nautilus"
        }
        return iconMap[appId] || appId
    }

    property string fallbackIcon: Quickshell.iconPath("application-x-executable-symbolic", false)

    function getIconPath(appId) {
        if (!appId) return fallbackIcon
        const iconName = getIconName(appId)
        const path = Quickshell.iconPath(iconName, true)
        return path !== "" ? path : fallbackIcon
    }

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Drop indicator
    Rectangle {
        visible: root.dragTargetIndex >= 0 && root.draggedItem !== null
        x: root.dragTargetIndex * (180 + taskRow.spacing)
        y: extraVerticalPadding
        width: 3
        height: parent.height - (extraVerticalPadding * 2)
        color: "#89b4fa"
        radius: 2
        z: 100
    }

    Row {
        id: taskRow
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 2

        Repeater {
            model: windowOrder

            Item {
                id: taskItem
                required property var modelData
                required property int index

                width: 180
                height: parent.height

                // Drag properties
                property bool isDragging: false
                property real dragStartX: 0

                Rectangle {
                    id: taskRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: parent.height - (extraVerticalPadding * 2)
                    color: modelData.activated ? "#45475a" : (taskMouse.containsMouse ? "#313244" : "transparent")
                    opacity: modelData.minimized ? 0.6 : 1.0
                    radius: 4

                    // Visual feedback when dragging
                    border.width: taskItem.isDragging ? 2 : 0
                    border.color: "#89b4fa"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Rectangle {
                            width: 20
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                source: getIconPath(modelData.appId)
                                sourceSize: Qt.size(20, 20)
                                layer.enabled: source == fallbackIcon
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: "white"
                                    brightness: 1.0
                                }
                            }
                        }

                        Text {
                            width: parent.width - 26
                            height: parent.height
                            text: modelData.title || "Window"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Menu {
                    id: contextMenu
                    popupType: Popup.Window

                    background: Rectangle {
                        implicitWidth: taskItem.width
                        color: "#1e1e2e"
                        border.color: "#45475a"
                        border.width: 1
                        radius: 4
                    }

                    MenuItem {
                        text: modelData.minimized ? "Restore" : "Minimize"
                        onTriggered: modelData.minimized = !modelData.minimized
                        contentItem: Text {
                            text: parent.text
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            leftPadding: 8
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#45475a" : "transparent"
                        }
                    }

                    MenuItem {
                        text: "Close"
                        onTriggered: modelData.requestClose()
                        contentItem: Text {
                            text: parent.text
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            leftPadding: 8
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#45475a" : "transparent"
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitWidth: taskItem.width
                            implicitHeight: 1
                            color: "#45475a"
                        }
                    }

                    MenuItem {
                        text: "Kill Process"
                        onTriggered: killProc.running = true
                        contentItem: Text {
                            text: parent.text
                            color: "#f38ba8"
                            font.pixelSize: 12
                            leftPadding: 8
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#45475a" : "transparent"
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
                            let itemWidth = taskItem.width + taskRow.spacing
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
                            contextMenu.popup(taskItem, 0, -contextMenu.implicitHeight - 5)
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
