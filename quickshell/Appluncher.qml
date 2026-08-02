import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Rectangle {
    id: appButton
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    // Define the process to run hyprlauncher
    Process {
        id: launcherProcess
        command: ["sh", "-c", "qs ipc call launcher toggle"]
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: "  App"
            color: mouseArea.containsMouse ? Colors.md3.primary : Colors.md3.on_surface

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                launcherProcess.running = true;
            }
        }
    }
}
