import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Rectangle {
    implicitWidth: row.implicitWidth + 25
    implicitHeight: row.implicitHeight + 10
    radius: implicitHeight / 2
    color: Colors.md3.surface_container

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        property var interfaceDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
        property var active: interfaceDevice ? interfaceDevice.networks.values.find(n => n.connected) : null

        readonly property real signal: active ? active.signalStrength : 0

        readonly property string icon: {
            if (!Networking.wifiEnabled)
                return String.fromCodePoint(0xF05AA);
            if (!active)
                return String.fromCodePoint(0xF092D);

            let tier = signal >= 0.75 ? 4 : signal >= 0.50 ? 3 : signal >= 0.25 ? 2 : 1;
            return String.fromCodePoint(0xF091F + (tier - 1) * 3);
        }

        Text {
            text: row.icon
            color: Networking.wifiEnabled ? Colors.md3.secondary : Colors.md3.error

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        Text {
            text: {
                if (!Networking.wifiEnabled)
                    return "off";
                if (!row.active)
                    return "Disconnected";

                return row.active.name;
            }
            color: Colors.md3.secondary

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }
    }
}
