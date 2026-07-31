import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "Colors.qml"

Rectangle {
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            Rectangle {
                id: trayItem
                required property var modelData

                implicitWidth: 15
                implicitHeight: 15
                radius: 4
                color: trayMouse.containsMouse ? Colors.md3.outline_variant : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Image {
                    anchors.centerIn: parent
                    width: 15
                    height: 15
                    source: modelData.icon
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            modelData.display(null, mouse.x, mouse.y);
                        }
                    }
                }
            }
        }
    }
}
