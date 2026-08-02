import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens

    ShellRoot {
        PanelWindow {
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 35
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                RowLayout {
                    spacing: 6

                    Appluncher {}
                    Lang {}
                    WindowName {}
                }

                RowLayout {
                    anchors.centerIn: parent

                    Workspaces {}
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 6

                    Tray {}
                    Privacy {}
                    SystemStatus {}
                    Network {}
                    Bluetooth {}
                    Volume {}
                    NotifIcon {}
                    Clock {}
                }
            }
            Notification {}
            Start {}
            HelpWindow {}
            Wallpaper {}
            Launcher {}
        }
    }
}
