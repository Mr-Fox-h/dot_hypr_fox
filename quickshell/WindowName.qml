import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "config.js" as Config
import "Colors.qml"

Rectangle {
    id: appButton
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.inverse_on_surface
    clip: true

    property var focusedWs: Hyprland.focusedWorkspace
    property var activeWindow: Hyprland.activeToplevel
    property bool hasWindow: activeWindow && focusedWs && activeWindow.workspace?.id === focusedWs.id

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: hasWindow ? activeWindow.title : ""
            color: Colors.md3.on_surface

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }
    }
}
