import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: clockRoot
    property bool popupVisible: false
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()

    width: clockColumn.width + 20
    height: parent.height

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfWeek(month, year) {
        var d = new Date(year, month, 1).getDay()
        return (d + 6) % 7
    }

    function buildCalendarModel() {
        var days = []
        var totalDays = daysInMonth(displayMonth, displayYear)
        var startDay = firstDayOfWeek(displayMonth, displayYear)

        var prevMonth = displayMonth === 0 ? 11 : displayMonth - 1
        var prevYear = displayMonth === 0 ? displayYear - 1 : displayYear
        var prevDays = daysInMonth(prevMonth, prevYear)

        for (var i = startDay - 1; i >= 0; i--)
            days.push({ day: prevDays - i, current: false, today: false })

        var now = new Date()
        var isCurrentMonth = now.getMonth() === displayMonth && now.getFullYear() === displayYear
        var todayDate = now.getDate()

        for (var d = 1; d <= totalDays; d++)
            days.push({ day: d, current: true, today: isCurrentMonth && d === todayDate })

        var remaining = 42 - days.length
        for (var n = 1; n <= remaining; n++)
            days.push({ day: n, current: false, today: false })

        return days
    }

    property var calendarDays: buildCalendarModel()

    onDisplayMonthChanged: calendarDays = buildCalendarModel()
    onDisplayYearChanged: calendarDays = buildCalendarModel()

    function monthName(month) {
        var names = ["January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December"]
        return names[month]
    }

    function prevMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear--
        } else {
            displayMonth--
        }
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear++
        } else {
            displayMonth++
        }
    }

    function resetToToday() {
        var now = new Date()
        displayMonth = now.getMonth()
        displayYear = now.getFullYear()
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: 32
        color: clockMouse.containsMouse || popupVisible ? "#33ffffff" : "transparent"
        radius: 5

        Column {
            id: clockColumn
            anchors.centerIn: parent
            spacing: 0

            TextMetrics {
                id: clockMetrics
                font: timeText.font
                text: "hh:mm:ss"
            }

            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#cdd6f4"
                font.pixelSize: 12
                font.family: "monospace"
                width: clockMetrics.width
            }

            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#a6adc8"
                font.pixelSize: 10
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    timeText.text = now.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
                    dateText.text = now.toLocaleDateString(Qt.locale(), "dd.MM.yyyy")
                }
            }
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (!popupVisible) resetToToday()
            popupVisible = !popupVisible
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

        WlrLayershell.namespace: "calendar-overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusiveZone: -1

        MouseArea {
            anchors.fill: parent
            onClicked: popupVisible = false
        }
    }

    // Calendar popup
    PanelWindow {
        id: calendarPopup
        visible: popupVisible

        anchors {
            bottom: true
            right: true
        }

        implicitWidth: 300
        implicitHeight: calendarBg.height

        WlrLayershell.namespace: "calendar-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        exclusiveZone: 0
        color: "transparent"

        mask: Region { item: calendarBg }

        Rectangle {
            id: calendarBg
            anchors.bottom: parent.bottom
            width: parent.width
            height: calendarContent.implicitHeight + 24
            color: "#1a1a1a"

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Column {
                id: calendarContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                spacing: 8

                // Month/Year header with navigation
                RowLayout {
                    width: parent.width
                    height: 30

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: prevMouse.containsMouse ? "#333333" : "transparent"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "\u2039"
                            color: "#cdd6f4"
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: clockRoot.prevMonth()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: clockRoot.monthName(clockRoot.displayMonth) + " " + clockRoot.displayYear
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: clockRoot.resetToToday()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: nextMouse.containsMouse ? "#333333" : "transparent"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "\u203a"
                            color: "#cdd6f4"
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: clockRoot.nextMonth()
                        }
                    }
                }

                // Day-of-week headers
                Grid {
                    columns: 7
                    width: parent.width

                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                        Item {
                            width: calendarContent.width / 7
                            height: 28

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: "#6c7086"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }

                // Calendar day grid
                Grid {
                    columns: 7
                    width: parent.width
                    rowSpacing: 2

                    Repeater {
                        model: clockRoot.calendarDays

                        Item {
                            width: calendarContent.width / 7
                            height: 32

                            Rectangle {
                                anchors.centerIn: parent
                                width: 30
                                height: 30
                                radius: 15
                                color: modelData.today ? "#2596be" : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                color: modelData.today ? "#1a1a1a" : (modelData.current ? "#cdd6f4" : "#45475a")
                                font.pixelSize: 12
                                font.bold: modelData.today
                            }
                        }
                    }
                }
            }
        }
    }
}
