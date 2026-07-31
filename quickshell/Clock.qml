import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "Colors.qml"

Rectangle {
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    RowLayout {
        id: row
        anchors.centerIn: parent

        SystemClock {
            id: clock
            precision: SystemClock.Second
        }
        Text {
            text: Qt.formatDateTime(clock.date, "   ddd dd HH:mm")
            color: Colors.md3.on_surface

            font {
                family: "Fira Code Medium"
                pixelSize: 12
                weight: 600
            }
        }
    }
}
