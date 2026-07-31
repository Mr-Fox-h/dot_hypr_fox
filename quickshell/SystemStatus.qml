import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Rectangle {
    id: sysMonitor
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    property real cpuUsage: 0
    property real memUsage: 0

    Process {
        id: statsProcess
        command: ["sh", "-c", "cpu=$(awk '/^cpu / {total=$2+$3+$4+$5+$6+$7+$8; used=$2+$4; printf \"%.0f\", used*100/total}' /proc/stat); " + "mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.0f\", (t-a)*100/t}' /proc/meminfo); " + "echo $cpu $mem"]

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(" ");
                if (parts.length === 2) {
                    sysMonitor.cpuUsage = parseFloat(parts[0]);
                    sysMonitor.memUsage = parseFloat(parts[1]);
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProcess.running = true
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        // CPU Section
        Text {
            text: "" // CPU Icon (Nerd Font)
            color: Colors.md3.on_surface
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        Text {
            text: sysMonitor.cpuUsage + "%"
            color: Colors.md3.on_surface
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        // Separator
        Rectangle {
            width: 1
            height: 12
            color: Colors.md3.outline_variant
            Layout.leftMargin: 2
            Layout.rightMargin: 2
        }

        // Memory Section
        Text {
            text: "" // Memory Icon (Nerd Font)
            color: Colors.md3.on_surface
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        Text {
            text: sysMonitor.memUsage + "%"
            color: Colors.md3.on_surface
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }
    }
}
