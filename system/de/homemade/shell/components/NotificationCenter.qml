import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root
    property bool popupVisible: false
    property var notifPopup

    width: 36
    height: parent.height

    Rectangle {
        anchors.centerIn: parent
        width: 32
        height: 32
        color: bellMouse.containsMouse || popupVisible ? "#33ffffff" : "transparent"
        radius: 5

        Text {
            anchors.centerIn: parent
            text: "󰂚"
            color: notifPopup && notifPopup.unreadCount > 0 ? "#f9e2af" : "#cdd6f4"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
        }

        // Unread badge
        Rectangle {
            visible: notifPopup && notifPopup.unreadCount > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 2
            width: Math.max(14, badgeText.implicitWidth + 6)
            height: 14
            radius: 7
            color: "#f38ba8"

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: notifPopup ? (notifPopup.unreadCount > 99 ? "99+" : notifPopup.unreadCount) : ""
                color: "#1a1a1a"
                font.pixelSize: 9
                font.bold: true
            }
        }
    }

    MouseArea {
        id: bellMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popupVisible = !popupVisible
            if (popupVisible && notifPopup) {
                notifPopup.markAllRead()
            }
        }
    }

    // Overlay to close popup when clicking outside
    PanelWindow {
        visible: popupVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "notif-center-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        MouseArea {
            anchors.fill: parent
            onClicked: popupVisible = false
        }
    }

    // Popup panel
    PanelWindow {
        id: centerPopup
        visible: popupVisible

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth: 380

        WlrLayershell.namespace: "notif-center"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0
        color: "transparent"

        mask: Region { item: popupBg }

        Rectangle {
            id: popupBg
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.min(popupContent.implicitHeight + 24, 600)
            color: "#1a1a1a"

            // Eat clicks so they don't reach the overlay
            MouseArea {
                anchors.fill: parent
                onClicked: {}
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

                    // Header
                    RowLayout {
                        width: parent.width
                        height: 30

                        Text {
                            text: "Notifications"
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            visible: notifPopup && notifPopup.historyModel.count > 0
                            width: clearText.implicitWidth + 16
                            height: 24
                            radius: 5
                            color: clearMouse.containsMouse ? "#333333" : "#2a2a2a"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                id: clearText
                                anchors.centerIn: parent
                                text: "Clear all"
                                color: "#a6adc8"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (notifPopup) notifPopup.clearHistory()
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#2a2a2a"
                    }

                    // Empty state
                    Text {
                        visible: !notifPopup || notifPopup.historyModel.count === 0
                        text: "No notifications"
                        color: "#6c7086"
                        font.pixelSize: 12
                    }

                    // Notification list
                    Repeater {
                        model: notifPopup ? notifPopup.historyModel : []

                        Rectangle {
                            width: popupContent.width
                            height: historyContent.implicitHeight + 20
                            radius: 8
                            color: historyItemMouse.containsMouse ? "#252525" : "#222222"

                            MouseArea {
                                id: historyItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            RowLayout {
                                id: historyContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Image {
                                    visible: (model.image !== "" && model.image !== undefined) || (model.appIcon !== "" && model.appIcon !== undefined)
                                    source: {
                                        if (model.image && model.image !== "") return model.image
                                        if (model.appIcon && model.appIcon !== "") return model.appIcon
                                        return ""
                                    }
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignTop
                                    sourceSize: Qt.size(32, 32)
                                    fillMode: Image.PreserveAspectFit
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Row {
                                        width: parent.width
                                        spacing: 6

                                        Text {
                                            visible: model.appName !== ""
                                            text: model.appName || ""
                                            color: "#888888"
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            text: model.time || ""
                                            color: "#555555"
                                            font.pixelSize: 10
                                        }
                                    }

                                    Text {
                                        text: model.summary || "Notification"
                                        color: "#cdd6f4"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: model.body !== "" && model.body !== undefined
                                        text: model.body || ""
                                        color: "#aaaaaa"
                                        font.pixelSize: 11
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                    }
                                }

                                // Remove button
                                Rectangle {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignTop
                                    radius: 9
                                    color: historyCloseMouse.containsMouse ? "#333333" : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\u00d7"
                                        color: "#666666"
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: historyCloseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (notifPopup) notifPopup.removeFromHistory(index)
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
}
