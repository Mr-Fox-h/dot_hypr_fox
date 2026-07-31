import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Rectangle {
    id: langButton
    implicitWidth: row.implicitWidth + 30
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2

    color: Colors.md3.surface_container

    property string currentLang: "us"

    Process {
        id: layoutProcess
        command: ["hyprctl", "devices", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let devices = JSON.parse(this.text);
                    let kb = devices.keyboards.find(k => k.main === true) || devices.keyboards[0];

                    if (kb && kb.active_keymap) {
                        let map = kb.active_keymap.toLowerCase();
                        if (map.includes("persian") || map.includes("iran") || map === "ir") {
                            langButton.currentLang = "ir";
                        } else {
                            langButton.currentLang = "us";
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse keyboard layout:", e);
                }
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: layoutProcess.running = true
    }

    RowLayout {
        id: row
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: langButton.currentLang
            color: Colors.md3.primary

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
            
        }
    }
}
