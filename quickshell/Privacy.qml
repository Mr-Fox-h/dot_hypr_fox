import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Rectangle {
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    property bool isMicActive: Pipewire.defaultAudioSource && !Pipewire.defaultAudioSource.audio.muted

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            implicitWidth: 15
            implicitHeight: 15
            radius: 4

            color: isMicActive ? Colors.md3.error_container : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: isMicActive ? Colors.md3.on_surface : Colors.md3.outline
                font {
                    family: Config.bar.fontFamily
                    pixelSize: Config.bar.fontSize
                    weight: 600
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (Pipewire.defaultAudioSource) {
                        Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
                    }
                }
            }
        }
    }
}
