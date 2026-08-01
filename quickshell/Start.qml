import Quickshell
import QtQuick
import Quickshell.Io
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Scope {
    id: root
    property bool startOpen: false

    IpcHandler {
        target: "start"
        function toggle(): void {
            root.startOpen = !root.startOpen;
        }
    }

    PanelWindow {
        visible: root.startOpen

        Process {
            id: powerFunc
            command: ["sh", "-c", "systemctl poweroff"]
        }

        Process {
            id: logoutFunc
            command: ["sh", "-c", "loginctl kill-session $XDG_SESSION_ID"]
        }

        Process {
            id: lockscreenFunc
            command: ["hyprlock"]
        }

        Process {
            id: rebootFunc
            command: ["systemctl", "reboot"]
        }

        Process {
            id: hibernateFunc
            command: ["sh", "-c", "hyprlock && systemctl hibernate"]
        }

        Process {
            id: suspendFunc
            command: ["sh", "-c", "systemctl suspend"]
        }

        anchors {
            right: true
        }

        implicitWidth: 100
        implicitHeight: Math.min(column.implicitHeight + 24, 600)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            topLeftRadius: 50
            bottomLeftRadius: 50
            color: Colors.md3.surface_container
            border.width: 1
            border.color: Colors.md3.surface_container_high

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    width: 80
                    height: 80
                    color: power.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    topLeftRadius: 50
                    bottomLeftRadius: 15
                    bottomRightRadius: 15
                    topRightRadius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: power.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: power.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: power
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            powerFunc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    color: logout.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    radius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰍃"
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: logout.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: logout.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: logout
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            logoutFunc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    color: lockscreen.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    radius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾"
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: lockscreen.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: lockscreen.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: lockscreen
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            lockscreenFunc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    color: reboot.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    radius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: reboot.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: reboot.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: reboot
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            rebootFunc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    color: hibernate.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    radius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: hibernate.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: hibernate.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: hibernate
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            hibernateFunc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    color: suspend.containsMouse ? Colors.md3.primary_fixed_dim : "transparent"
                    topLeftRadius: 15
                    bottomLeftRadius: 50
                    bottomRightRadius: 15
                    topRightRadius: 15

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒲"
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: 32
                            bold: true
                        }
                        color: suspend.containsMouse ? Colors.md3.surface_container : Colors.md3.on_surface_variant
                        scale: suspend.containsMouse ? 1.3 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: suspend
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            suspendFunc.running = true;
                        }
                    }
                }
            }
        }
    }
}
