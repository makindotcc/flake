import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root
    property var screen: null
    property bool popupVisible: false
    property bool _initialized: false
    property var _cachedSorted: []
    property string _query: ""
    property int _confirmIndex: -1  // which power button is awaiting confirmation

    Component.onCompleted: {
        _rebuildCache()
        _initialized = true
    }

    function _rebuildCache() {
        _cachedSorted = [...DesktopEntries.applications.values].sort((a, b) =>
            (a.name || "").localeCompare(b.name || ""))
        _updateFilter()
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root._rebuildCache() }
    }

    // Power commands
    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }
    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }
    Process {
        id: sleepProc
        command: ["systemctl", "suspend"]
    }
    Process {
        id: logoutProc
        command: ["labwc", "--exit"]
    }
    Process {
        id: lockProc
        command: ["swaylock"]
    }

    function toggle() {
        popupVisible = !popupVisible
    }

    function close() {
        popupVisible = false
    }

    function _updateFilter() {
        const q = _query
        if (q === "") {
            filteredApps.values = root._cachedSorted
            return
        }
        filteredApps.values = root._cachedSorted.filter(entry => {
            const name = (entry.name || "").toLowerCase()
            const generic = (entry.genericName || "").toLowerCase()
            const comment = (entry.comment || "").toLowerCase()
            const kw = (entry.keywords || []).join(" ").toLowerCase()
            return name.includes(q) || generic.includes(q) || comment.includes(q) || kw.includes(q)
        }).sort((a, b) => {
            const aName = (a.name || "").toLowerCase()
            const bName = (b.name || "").toLowerCase()
            const aStarts = aName.startsWith(q)
            const bStarts = bName.startsWith(q)
            if (aStarts && !bStarts) return -1
            if (!aStarts && bStarts) return 1
            return aName.localeCompare(bName)
        })
    }

    onPopupVisibleChanged: {
        _confirmIndex = -1
        if (popupVisible) {
            searchInput.text = ""
            _query = ""
            filteredApps.values = root._cachedSorted
            listView.currentIndex = 0
        }
    }

    ScriptModel {
        id: filteredApps
        values: root._cachedSorted
    }

    // Overlay to close launcher on outside click
    PanelWindow {
        visible: root.popupVisible
        screen: root.screen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "launcher-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        mask: Region {
            item: root.popupVisible ? overlayMouseArea : null
        }

        MouseArea {
            id: overlayMouseArea
            anchors.fill: parent
            onClicked: (mouse) => {
                root.close()
                
                console.log("Clicked outside launcher, closing", mouse)
                mouse.accepted = false;
            }
        }
    }

    // Launcher popup
    PanelWindow {
        id: launcherPopup
        visible: root.popupVisible || slideAnim.running
        screen: root.screen

        anchors {
            bottom: true
            left: true
        }

        implicitWidth: 400
        implicitHeight: 500

        WlrLayershell.namespace: "app-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.popupVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        exclusiveZone: 0
        color: "transparent"

        mask: Region {
            item: root.popupVisible || slideAnim.running ? launcherInputArea : null
        }

        Item {
            id: launcherInputArea
            anchors.fill: parent
        }

        Item {
            anchors.fill: parent
            clip: true

            // Sliding content
            Rectangle {
            id: slideContent
            width: parent.width
            height: parent.height
            color: "#1a1a1a"

            transform: Translate {
                id: slideTranslate
                y: root.popupVisible ? 0 : launcherPopup.implicitHeight

                Behavior on y {
                    enabled: root._initialized
                    NumberAnimation {
                        id: slideAnim
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Eat clicks so overlay doesn't get them
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Item {
                anchors.fill: parent
                anchors.margins: 12

            // Search box
            Rectangle {
                id: searchBox
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                radius: 8
                color: "#252525"

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: ""
                        color: "#6c7086"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: searchInput
                        width: parent.width - 30
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        clip: true
                        focus: root.popupVisible


                        onTextChanged: {
                            root._query = text.trim().toLowerCase()
                            root._updateFilter()
                            listView.currentIndex = 0
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.close()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                if (listView.currentIndex < filteredApps.values.length - 1) {
                                    listView.currentIndex++
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                if (listView.currentIndex > 0) {
                                    listView.currentIndex--
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (listView.currentIndex >= 0 && listView.currentIndex < filteredApps.values.length) {
                                    filteredApps.values[listView.currentIndex].execute()
                                    root.close()
                                }
                                event.accepted = true
                            }
                        }

                        // Placeholder text
                        Text {
                            visible: searchInput.text === ""
                            text: "Search applications..."
                            color: "#6c7086"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // App list
            ListView {
                id: listView
                anchors.top: searchBox.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: separator.top
                anchors.bottomMargin: 8
                clip: true
                model: filteredApps.values
                currentIndex: 0
                highlightMoveDuration: 80
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 13000
                cacheBuffer: 800
                reuseItems: true

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onWheel: wheel => {
                        listView.flick(0, wheel.angleDelta.y * 15)
                        wheel.accepted = true
                    }
                    onClicked: mouse => { mouse.accepted = false }
                    onPressed: mouse => { mouse.accepted = false }
                    onReleased: mouse => { mouse.accepted = false }
                }

                delegate: Rectangle {
                    id: delegateItem
                    required property var modelData
                    required property int index

                    width: listView.width
                    height: 44
                    radius: 6
                    property bool _selected: index === listView.currentIndex
                    color: delegateMouse.containsMouse ? "#2a2a2a"
                        : _selected ? "#222222"
                        : "transparent"

                    // Cache icon path to avoid re-lookup
                    property string _iconSource: modelData.icon
                        ? Quickshell.iconPath(modelData.icon, true)
                        : ""

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        IconImage {
                            source: delegateItem._iconSource
                            implicitWidth: 28
                            implicitHeight: 28
                            anchors.verticalCenter: parent.verticalCenter
                            asynchronous: true
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 46
                            spacing: 1

                            Text {
                                text: delegateItem.modelData.name || ""
                                color: delegateMouse.containsMouse || delegateItem._selected ? "#2596be" : "#cdd6f4"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                visible: text !== ""
                                text: delegateItem.modelData.genericName || ""
                                color: "#6c7086"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        id: delegateMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            delegateItem.modelData.execute()
                            root.close()
                        }
                    }
                }

                // Empty state
                Text {
                    visible: filteredApps.values.length === 0
                    anchors.centerIn: parent
                    text: "No applications found"
                    color: "#6c7086"
                    font.pixelSize: 13
                }
            }

            // Separator
            Rectangle {
                id: separator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: powerRow.top
                anchors.bottomMargin: 8
                height: 1
                color: "#2a2a2a"
            }

            // Power buttons row
            Item {
                id: powerRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 40

                // Normal button row
                Row {
                    anchors.fill: parent
                    spacing: 4
                    visible: root._confirmIndex === -1

                    Repeater {
                        model: [
                            { icon: "󰌾", color: "#2596be", label: "Lock" },
                            { icon: "󰤄", color: "#f9e2af", label: "Sleep" },
                            { icon: "󰜉", color: "#94e2d5", label: "Restart" },
                            { icon: "󰍃", color: "#cba6f7", label: "Logout" },
                            { icon: "󰐥", color: "#f38ba8", label: "Shutdown" }
                        ]

                        Rectangle {
                            required property var modelData
                            required property int index
                            width: (powerRow.width - 4 * 4) / 5
                            height: 40
                            radius: 6
                            color: powerBtnMouse.containsMouse ? "#2a2a2a" : "transparent"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    text: modelData.icon
                                    color: modelData.color
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: modelData.label
                                    color: "#6c7086"
                                    font.pixelSize: 9
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: powerBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root._confirmIndex = index
                            }
                        }
                    }
                }

                // Confirmation row
                Row {
                    anchors.fill: parent
                    spacing: 8
                    visible: root._confirmIndex !== -1

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            const labels = ["Lock?", "Sleep?", "Restart?", "Logout?", "Shutdown?"]
                            return root._confirmIndex >= 0 ? labels[root._confirmIndex] : ""
                        }
                        color: "#cdd6f4"
                        font.pixelSize: 13
                    }

                    Item { width: 1; height: 1; Layout.fillWidth: true }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 30
                        radius: 6
                        color: cancelMouse.containsMouse ? "#2a2a2a" : "#222222"

                        Text {
                            anchors.centerIn: parent
                            text: "No"
                            color: "#6c7086"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root._confirmIndex = -1
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 30
                        radius: 6
                        color: confirmMouse.containsMouse ? "#3a2a2a" : "#2a2222"

                        Text {
                            anchors.centerIn: parent
                            text: "Yes"
                            color: "#f38ba8"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: confirmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                const procs = [lockProc, sleepProc, rebootProc, logoutProc, shutdownProc]
                                const proc = procs[root._confirmIndex]
                                root._confirmIndex = -1
                                root.close()
                                proc.running = true
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
