import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "Colors.qml"

Rectangle {
    implicitWidth: row.implicitWidth + 12
    implicitHeight: row.implicitHeight + 8
    radius: implicitHeight / 2
    color: Colors.md3.surface_container_low

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                id: wsButton
                required property var modelData

                property bool isActive: modelData.focused
                property bool hasWindows: modelData.lastIpcObject?.windows > 0 || modelData.active
                property bool isSpecial: modelData.name === "special" || modelData.name.startsWith("special:") || modelData.id === -99
                property bool isVisible: hasWindows || isSpecial

                property bool isHovered: mouseArea.containsMouse

                implicitWidth: isActive ? 53 : (isVisible ? 30 : 0)
                implicitHeight: 18
                radius: implicitHeight / 2

                color: isActive ? Colors.md3.primary : (isSpecial ? Colors.md3.inverse_primary : (isHovered ? Colors.md3.on_secondary : (isVisible ? Colors.md3.inverse_on_surface : "transparent")))

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBounce
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: modelData.activate()
                }
            }
        }
    }
}
