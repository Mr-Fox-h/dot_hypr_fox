import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Hyprland

import "config.js" as Config
import "Colors.qml"

FloatingWindow {
    id: root
    visible: false
    width: 1000
    height: 550
    color: Colors.md3.surface_container_low
    title: "Hyprland Keybinds"
    maximumSize: Qt.size(1000, 550)
    minimumSize: Qt.size(1000, 550)

    // Close on Escape key
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.visible = false;
        }
    }

    IpcHandler {
        target: "help"
        function toggle(): void {
            root.visible = !root.visible;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // Header
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "<b>Hyprland Keybinds</b>"
            color: Colors.md3.primary
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize + 8
            }
        }

        // Tab bar
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle {
                color: "transparent"
            }
            spacing: 0

            Repeater {
                model: sectionsModel
                TabButton {
                    text: modelData.sectionName
                    height: 25
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize
                    // Styling
                    background: Rectangle {
                        color: tabBar.currentIndex === index ? Colors.md3.primary_container : "transparent"
                        radius: height / 2
                        opacity: tabBar.currentIndex === index ? 1 : 0.8
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === index ? Colors.md3.on_primary_container : Colors.md3.on_surface
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // Stack of pages
        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Repeater {
                model: sectionsModel
                Rectangle {
                    color: Colors.md3.surface_container
                    radius: 10
                    border.width: 1
                    border.color: Colors.md3.surface_container_high
                    clip: true

                    // Scrollable list for keybinds
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 5
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        ListView {
                            id: listView
                            model: modelData.keybinds
                            delegate: ItemDelegate {
                                background: Rectangle {
                                    color: "transparent"
                                    radius: 4
                                }
                                width: ListView.view.width
                                height: 40
                                highlighted: ListView.isCurrentItem
                                padding: 0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15

                                    Text {

                                        Layout.preferredWidth: 220
                                        Layout.minimumWidth: 220
                                        text: modelData.key
                                        color: Colors.md3.on_surface
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize
                                        font.bold: true
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.action
                                        color: Colors.md3.on_surface_variant
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }

                                // Separator line
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: Colors.md3.surface_container_high
                                    visible: index < ListView.view.count - 1
                                }
                            }
                        }
                    }
                }
            }
        }

        // Close button
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Rectangle {
                width: 70
                height: 35
                radius: 10
                color: closeArea.containsMouse ? Colors.md3.surface_bright : Colors.md3.inverse_on_surface

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    color: closeArea.containsMouse ? Colors.md3.primary_fixed : Colors.md3.primary
                    font {
                        family: Config.bar.fontFamily
                        pixelSize: Config.bar.fontSize
                    }
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.visible = false
                }
            }
        }
    }

    // Data model
    property var sectionsModel: [
        {
            sectionName: "   Window Action",
            keybinds: [
                {
                    key: "Super + Q",
                    action: "Close Active Window"
                },
                {
                    key: "Super + F",
                    action: "Toggle Fullscreen"
                },
                {
                    key: "Super + Alt + Space",
                    action: "Toggle Floating"
                },
                {
                    key: "Super + P",
                    action: "Pseudo Tiling (Dwindle)"
                },
                {
                    key: "Super + J",
                    action: "Toggle Split (Dwindle)"
                },
                {
                    key: "Super + left",
                    action: "Move Focus Left"
                },
                {
                    key: "Super + right",
                    action: "Move Focus Right"
                },
                {
                    key: "Super + up",
                    action: "Move Focus Up"
                },
                {
                    key: "Super + down",
                    action: "Move Focus Down"
                },
                {
                    key: "Super + Shift + left",
                    action: "Move Window Left"
                },
                {
                    key: "Super + Shift + right",
                    action: "Move Window Right"
                },
                {
                    key: "Super + Shift + up",
                    action: "Move Window Up"
                },
                {
                    key: "Super + Shift + down",
                    action: "Move Window Down"
                }
            ]
        },
        {
            sectionName: "   Applications",
            keybinds: [
                {
                    key: "Super + T",
                    action: "Open Terminal"
                },
                {
                    key: "Super + E",
                    action: "Open File Manager"
                },
                {
                    key: "Super + Tab",
                    action: "Open App Launcher"
                },
                {
                    key: "Super + Y",
                    action: "Open hyprlauncher"
                },
                {
                    key: "Super + W",
                    action: "Open Zen Browser"
                },
                {
                    key: "Super + M",
                    action: "Open Music Player"
                },
                {
                    key: "Super + V",
                    action: "Open Hiddify VPN"
                },
                {
                    key: "Super + End",
                    action: "Open System Monitor (btop)"
                }
            ]
        },
        {
            sectionName: "   Media & Screenshots",
            keybinds: [
                {
                    key: "Print",
                    action: "Screenshot Window"
                },
                {
                    key: "Super + Shift + S",
                    action: "Screenshot Region"
                }
            ]
        },
        {
            sectionName: "   OS & System",
            keybinds: [
                {
                    key: "Super + L",
                    action: "Lock Screen"
                },
                {
                    key: "Ctrl + Alt + Delete",
                    action: "Logout Menu"
                },
                {
                    key: "Super + I",
                    action: "System Information"
                },
                {
                    key: "Super + R",
                    action: "hyprland-run"
                },
                {
                    key: "Super + N",
                    action: "Toggle Notifications"
                },
                {
                    key: "Super + H",
                    action: "Open This Help Window"
                },
                {
                    key: "Super + B",
                    action: "Open Change Background Window"
                },
                {
                    key: "Super + C",
                    action: "Color Picker"
                },
                {
                    key: "Super + Space",
                    action: "Change Language Layout"
                }
            ]
        },
        {
            sectionName: "󰨇   Workspaces",
            keybinds: [
                {
                    key: "Super + 1",
                    action: "Switch to Workspace 1"
                },
                {
                    key: "Super + 2",
                    action: "Switch to Workspace 2"
                },
                {
                    key: "Super + 3",
                    action: "Switch to Workspace 3"
                },
                {
                    key: "Super + 4",
                    action: "Switch to Workspace 4"
                },
                {
                    key: "Super + 5",
                    action: "Switch to Workspace 5"
                },
                {
                    key: "Super + 6",
                    action: "Switch to Workspace 6"
                },
                {
                    key: "Super + 7",
                    action: "Switch to Workspace 7"
                },
                {
                    key: "Super + 8",
                    action: "Switch to Workspace 8"
                },
                {
                    key: "Super + 9",
                    action: "Switch to Workspace 9"
                },
                {
                    key: "Super + 0",
                    action: "Switch to Workspace 10"
                },
                {
                    key: "Super + Shift + 1",
                    action: "Move Window to Workspace 1"
                },
                {
                    key: "Super + Shift + 2",
                    action: "Move Window to Workspace 2"
                },
                {
                    key: "Super + Shift + 3",
                    action: "Move Window to Workspace 3"
                },
                {
                    key: "Super + Shift + 4",
                    action: "Move Window to Workspace 4"
                },
                {
                    key: "Super + Shift + 5",
                    action: "Move Window to Workspace 5"
                },
                {
                    key: "Super + Shift + 6",
                    action: "Move Window to Workspace 6"
                },
                {
                    key: "Super + Shift + 7",
                    action: "Move Window to Workspace 7"
                },
                {
                    key: "Super + Shift + 8",
                    action: "Move Window to Workspace 8"
                },
                {
                    key: "Super + Shift + 9",
                    action: "Move Window to Workspace 9"
                },
                {
                    key: "Super + Shift + 0",
                    action: "Move Window to Workspace 10"
                }
            ]
        },
        {
            sectionName: "󱄄   Special Workspaces",
            keybinds: [
                {
                    key: "Super + S",
                    action: "Toggle Special Workspace 'magic'"
                },
                {
                    key: "Super + Alt + S",
                    action: "Move Window to Special Workspace"
                },
                {
                    key: "Super + X",
                    action: "Minimize Window"
                },
                {
                    key: "Super + mouse_down",
                    action: "Next Workspace"
                },
                {
                    key: "Super + mouse_up",
                    action: "Previous Workspace"
                }
            ]
        }
    ]
}
