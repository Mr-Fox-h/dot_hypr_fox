import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

import "Colors.qml"

Rectangle {
    id: btWidget
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    // Holds the status: "OFF", "DISCONNECTED", or the Device Name
    property string status: "OFF"

    // Dynamic Icon based on status (Requires Nerd Fonts)
    readonly property string icon: {
        if (status === "OFF")
            return String.fromCodePoint(0xF00B2);       // Bluetooth Off
        if (status === "DISCONNECTED")
            return String.fromCodePoint(0xF00AF); // Bluetooth
        return String.fromCodePoint(0xF00B1);                             // Bluetooth Connected
    }

    // Dynamic Text Color
    readonly property color textColor: status === "OFF" ? Colors.md3.error : Colors.md3.secondary

    // Process to fetch Bluetooth status
    Process {
        id: btProcess
        command: ["sh", "-c", "p=$(bluetoothctl show 2>/dev/null | grep Powered | awk '{print $2}'); " + "if [ \"$p\" != \"yes\" ]; then echo OFF; exit 0; fi; " + "d=$(bluetoothctl devices Connected 2>/dev/null | head -1); " + "if [ -z \"$d\" ]; then echo DISCONNECTED; " + "else m=$(echo $d | awk '{print $2}'); " + "n=$(bluetoothctl info $m 2>/dev/null | grep '^Name:' | head -1 | sed 's/^Name: //'); " + "echo $n; fi"]

        stdout: StdioCollector {
            onStreamFinished: {
                let out = text.trim();
                if (out === "OFF" || out === "DISCONNECTED" || out === "") {
                    btWidget.status = out || "DISCONNECTED";
                } else {
                    // It's the device name
                    btWidget.status = out;
                }
            }
        }
    }

    // Poll every 3 seconds (bluetoothctl is slightly heavier than reading /proc)
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btProcess.running = true
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: btWidget.icon
            color: btWidget.textColor

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        Text {
            text: {
                if (btWidget.status === "OFF")
                    return "off";
                if (btWidget.status === "DISCONNECTED")
                    return "Disconnected";
                return btWidget.status; // Returns the actual device name
            }
            color: btWidget.textColor

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }
    }
}
