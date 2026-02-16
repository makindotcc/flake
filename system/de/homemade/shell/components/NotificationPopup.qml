import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Item {
    id: root

    property int activeCount: 0
    property alias historyModel: historyModel
    property int unreadCount: 0

    function markAllRead() {
        unreadCount = 0
    }

    function clearHistory() {
        historyModel.clear()
        unreadCount = 0
    }

    function removeFromHistory(index) {
        historyModel.remove(index)
    }

    ListModel {
        id: historyModel
    }

    NotificationServer {
        id: server
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
            notifComponent.createObject(notifColumn, {notification: notification})
            root.activeCount++

            historyModel.insert(0, {
                appName: notification.appName || "",
                appIcon: notification.appIcon || "",
                summary: notification.summary || "",
                body: notification.body || "",
                image: notification.image || "",
                time: Qt.formatTime(new Date(), "HH:mm"),
                urgency: notification.urgency
            })
            root.unreadCount++
            if (historyModel.count > 100) {
                historyModel.remove(historyModel.count - 1)
            }
        }
    }

    Component {
        id: notifComponent

        Item {
            id: notifWrapper
            required property var notification
            property bool isClosing: false
            property bool isExpire: false

            function slideOutAndRemove(expire) {
                if (isClosing) return
                isClosing = true
                isExpire = expire
                slideIn.stop()
                expandAnim.stop()
                slideOut.from = notifItem.x
                slideOut.start()
            }

            width: 360
            height: 0
            clip: true

            Rectangle {
                id: notifItem
                width: 360
                height: contentColumn.implicitHeight + 24
                radius: 10
                color: "#ee1a1a1a"
                border.color: "#2a2a2a"
                border.width: 1
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // App icon
                    Image {
                        visible: notifWrapper.notification.image !== "" || notifWrapper.notification.appIcon !== ""
                        source: notifWrapper.notification.image !== "" ? notifWrapper.notification.image : (notifWrapper.notification.appIcon !== "" ? notifWrapper.notification.appIcon : "")
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignTop
                        sourceSize: Qt.size(36, 36)
                        fillMode: Image.PreserveAspectFit
                    }

                    Column {
                        id: contentColumn
                        Layout.fillWidth: true
                        spacing: 4

                        // App name
                        Text {
                            visible: notifWrapper.notification.appName !== ""
                            text: notifWrapper.notification.appName
                            color: "#888888"
                            font.pixelSize: 11
                            width: parent.width
                            elide: Text.ElideRight
                        }

                        // Summary
                        Text {
                            text: notifWrapper.notification.summary || "Notification"
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.bold: true
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // Body
                        Text {
                            visible: notifWrapper.notification.body !== ""
                            text: notifWrapper.notification.body
                            color: "#aaaaaa"
                            font.pixelSize: 12
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }

                        // Actions
                        Row {
                            visible: notifWrapper.notification.actions.length > 0
                            spacing: 6

                            Repeater {
                                model: notifWrapper.notification.actions

                                Rectangle {
                                    required property var modelData

                                    width: actionText.implicitWidth + 16
                                    height: 26
                                    radius: 5
                                    color: actionMouse.containsMouse ? "#333333" : "#2a2a2a"

                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        color: "#cdd6f4"
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: actionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            modelData.invoke()
                                            notifWrapper.slideOutAndRemove(false)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Close button
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignTop
                        radius: 10
                        color: closeMouse.containsMouse ? "#333333" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "\u00d7"
                            color: "#888888"
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: notifWrapper.slideOutAndRemove(false)
                        }
                    }
                }
            }

            // Height expand (on create) — 'to' set dynamically after layout settles
            NumberAnimation {
                id: expandAnim
                target: notifWrapper
                property: "height"
                from: 0
                duration: 200
                easing.type: Easing.OutCubic
                onFinished: notifWrapper.height = Qt.binding(() => notifItem.height)
            }

            // Height collapse (after slide-out)
            NumberAnimation {
                id: collapseAnim
                target: notifWrapper
                property: "height"
                to: 0
                duration: 150
                easing.type: Easing.InCubic
                onFinished: {
                    if (notifWrapper.isExpire) {
                        notifWrapper.notification.expire()
                    } else {
                        notifWrapper.notification.dismiss()
                    }
                    root.activeCount--
                    notifWrapper.destroy()
                }
            }

            // Slide in from right
            NumberAnimation {
                id: slideIn
                target: notifItem
                property: "x"
                from: 400
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }

            // Slide out to right, then collapse height
            NumberAnimation {
                id: slideOut
                target: notifItem
                property: "x"
                to: 400
                duration: 200
                easing.type: Easing.InCubic
                onFinished: {
                    collapseAnim.from = notifWrapper.height
                    collapseAnim.start()
                }
            }

            Component.onCompleted: {
                // Defer to next frame so layout has settled and notifItem.height is correct
                Qt.callLater(function() {
                    expandAnim.to = notifItem.height
                    expandAnim.start()
                    slideIn.start()
                })
            }

            // Auto-expire timer (skip for critical)
            Timer {
                running: notifWrapper.notification.urgency !== NotificationUrgency.Critical
                interval: notifWrapper.notification.expireTimeout > 0 ? notifWrapper.notification.expireTimeout * 1000 : 5000
                repeat: false
                onTriggered: notifWrapper.slideOutAndRemove(true)
            }
        }
    }

    // Popup window — full height to avoid compositor resize lag
    PanelWindow {
        id: popupWindow
        visible: root.activeCount > 0

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth: 380

        WlrLayershell.namespace: "notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: 0
        color: "transparent"

        // Only notification area accepts input, rest is click-through
        mask: Region { item: notifColumn }

        Column {
            id: notifColumn
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 6
            width: 360
            spacing: 6
        }
    }
}
