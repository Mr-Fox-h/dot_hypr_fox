import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Layouts

import "config.js" as Config
import "Colors.qml"

Scope {
    id: root
    property bool centerOpen: false

    ListModel {
        id: history
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:MM")  // fixed typo: Data → Date
            });
            n.tracked = true;
        }
    }

    IpcHandler {
        target: "notification"
        function toggle(): void {
            root.centerOpen = !root.centerOpen;
        }
        function show(): void {
            root.centerOpen = true;
        }
        function hide(): void {
            root.centerOpen = false;
        }
    }

    // Single notification
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 35
            right: 12
        }

        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: Config.notifications.timeout
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 20
                    radius: 10
                    color: Colors.md3.background
                    border.width: 1
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Colors.md3.on_error : Colors.md3.surface_container_high

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectfit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Colors.md3.primary
                                elide: Text.ElideRight

                                font {
                                    family: Config.bar.fontFamily
                                    pixelSize: Config.bar.fontSize
                                    bold: true
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Colors.md3.on_surface
                                wrapMode: Text.WordWrap

                                font {
                                    family: Config.bar.fontFamily
                                    pixelSize: Config.bar.fontSize - 1
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: card.modelData.dismiss()
                        }
                    }
                }
            }
        }
    }

    // Notification center
    PanelWindow {
        visible: root.centerOpen
        anchors {
            top: true
            right: true
        }
        margins {
            top: 35
            right: 12
        }
        implicitWidth: 380
        implicitHeight: Math.min(centerCol.implicitHeight + 24, 600)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Colors.md3.surface_container
            border.width: 1
            border.color: Colors.md3.surface_container_high

            ColumnLayout {
                id: centerCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Audio player
                Rectangle {
                    id: audioText
                    Layout.fillWidth: true
                    radius: 10
                    height: 100
                    color: Colors.md3.inverse_on_surface
                    border.width: 1
                    border.color: Colors.md3.surface_container_high

                    property MprisPlayer activePlayer: {
                        var players = Mpris.players.values;
                        // Prefer Spotify, otherwise pick the first available
                        for (var i = 0; i < players.length; i++) {
                            if (players[i].identity.toLowerCase() === "spotify")
                                return players[i];
                        }
                        return players.length > 0 ? players[0] : null;
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 20

                        Rectangle {
                            id: albumArtContainer
                            width: 80
                            height: 80
                            color: Colors.md3.outline
                            radius: 10
                            clip: true

                            property string artUrl: audioText.activePlayer ? audioText.activePlayer.trackArtUrl : ""

                            Image {
                                id: albumArt
                                anchors.fill: parent
                                source: albumArtContainer.artUrl
                                visible: source.toString() !== "" && source !== undefined && source !== null
                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: maskRect
                                }
                            }
                            Rectangle {
                                id: maskRect
                                width: albumArtContainer.width
                                height: albumArtContainer.height
                                radius: albumArtContainer.radius
                                visible: false   // only used as a mask source
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰎈"
                                font {
                                    family: Config.bar.fontFamily
                                    pixelSize: 32
                                    bold: true
                                }
                                color: Colors.md3.on_surface_variant
                                visible: !albumArt.visible
                            }
                        }

                        ColumnLayout {
                            Text {
                                Layout.fillWidth: true
                                text: audioText.activePlayer ? (audioText.activePlayer.trackTitle || "No Music") : "No Music"
                                color: Colors.md3.on_surface_variant
                                elide: Text.ElideRight
                                font {
                                    family: Config.bar.fontFamily
                                    pixelSize: Config.bar.fontSize
                                    bold: true
                                }
                            }

                            Text {
                                text: audioText.activePlayer ? (audioText.activePlayer.trackArtist || "No Artist") : "No Artist"
                                color: Colors.md3.on_surface_variant
                                elide: Text.ElideRight
                                font {
                                    family: Config.bar.fontFamily
                                    pixelSize: Config.bar.fontSize - 3
                                    bold: true
                                }
                            }
                        }
                    }

                    // MouseArea {
                    //     anchors.fill: parent
                    //     onClicked: {
                    //         if (audioText.activePlayer) {
                    //             audioText.activePlayer.togglePlaying();
                    //         }
                    //     }
                    // }
                }

                // Notification Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Colors.md3.primary
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: Config.bar.fontSize
                            bold: true
                        }
                    }

                    Text {
                        text: "Clear all"
                        visible: history.count > 0
                        color: Colors.md3.error
                        font {
                            family: Config.bar.fontFamily
                            pixelSize: Config.bar.fontSize - 1
                            bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: history.clear()
                        }
                    }
                }

                // Notification list (dynamic height)
                ListView {
                    id: historyListView
                    model: history
                    Layout.fillWidth: true
                    height: contentHeight
                    Layout.preferredHeight: height
                    interactive: true
                    spacing: 8

                    delegate: Rectangle {
                        id: itemCard
                        required property var modelData
                        required property int index

                        width: historyListView.width
                        height: itemLayout.implicitHeight + 20
                        radius: 8
                        color: Colors.md3.surface_container_low
                        border.width: 1
                        border.color: Colors.md3.surface_container_high

                        RowLayout {
                            id: itemLayout
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Image {
                                Layout.preferredHeight: 36
                                Layout.preferredWidth: 36
                                Layout.alignment: Qt.AlignTop
                                fillMode: Image.PreserveAspectfit
                                visible: false // since we don't store images yet
                                source: ""
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.summary
                                    color: modelData.urgency === NotificationUrgency.Critical ? Colors.md3.error : Colors.md3.primary
                                    elide: Text.ElideRight
                                    font {
                                        family: Config.bar.fontFamily
                                        pixelSize: Config.bar.fontSize
                                        bold: true
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: modelData.body
                                    color: Colors.md3.on_surface
                                    wrapMode: Text.WordWrap
                                    font {
                                        family: Config.bar.fontFamily
                                        pixelSize: Config.bar.fontSize - 1
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.appName + " | " + modelData.time
                                    color: Colors.md3.on_tertiary_fixed_variant
                                    font.pixelSize: Config.bar.fontSize - 2
                                }
                            }

                            // Dismiss button (×)
                            Text {
                                text: ""
                                color: Colors.md3.on_tertiary_fixed_variant
                                font.pixelSize: Config.bar.fontSize + 2
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        history.remove(index);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
