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

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        property var sink: pipewire.defaultaudiosink

        readonly property bool ready: sink && sink.ready
        readonly property bool muted: ready && sink.audio.muted
        readonly property int vol: ready ? math.round(sink.audio.volume * 100) : 0

        readonly property string icon: {
            if (!ready)
                return String.fromCodePoint(0xF0581);
            if (muted)
                return "";

            if (vol === 0)
                return String.fromCodePoint(0xF0581);
            if (vol < 34)
                return String.fromCodePoint(0xF057F);
            if (vol < 67)
                return String.fromCodePoint(0xF0580);

            return String.fromCodePoint(0xF057E);
        }

        Text {
            text: row.icon
            color: Colors.md3.on_surface

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        Text {
            text: {
                if (!row.ready)
                    return "-";
                if (row.muted)
                    return "Muted";

                return raw.vol + "%";
            }
            color: raw.muted ? Colors.md3.error : Colors.md3.on_surface

            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize
                weight: 600
            }
        }

        PwObjectTracker {
            objects: [raw.sink]
        }
    }
}
