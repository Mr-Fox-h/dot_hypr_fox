import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

import "config.js" as Config
import "Colors.qml"

Scope {
    id: root

    IpcHandler {
        target: "launcher"
        function toggle() {
            launcher.visible = !launcher.visible;
            if (launcher.visible) {
                launcher.forceActiveFocus();
                Qt.callLater(() => {
                    searchField.forceActiveFocus();
                    searchField.selectAll();
                });
                if (appList.count > 0)
                    appList.currentIndex = 0;
            }
        }
    }

    PanelWindow {
        id: launcher
        visible: false
        focusable: true
        property string query: ""

        anchors {
            top: true
            left: true
        }

        margins {
            top: 35
            left: 12
        }

        implicitWidth: 800
        implicitHeight: 500
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        onVisibleChanged: {
            if (visible) {
                launcher.forceActiveFocus();
                Qt.callLater(() => {
                    searchField.forceActiveFocus();
                    searchField.selectAll();
                });
                if (appList.count > 0)
                    appList.currentIndex = 0;
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (searchField.text.length > 0) {
                    searchField.text = "";
                    event.accepted = true;
                } else {
                    launcher.visible = false;
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 15
            color: Colors.md3.surface_container
            border.width: 1
            border.color: Colors.md3.surface_container_high

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Search Input
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 10
                    color: Colors.md3.surface_container_high

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 8
                        spacing: 8

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            verticalAlignment: TextInput.AlignVCenter
                            placeholderText: "Search applications..."
                            placeholderTextColor: Colors.md3.on_surface_variant
                            color: Colors.md3.on_surface
                            font {
                                family: Config.bar.fontFamily
                                pixelSize: Config.bar.fontSize
                                bold: true
                            }
                            focus: true
                            activeFocusOnTab: true

                            onTextChanged: {
                                launcher.query = text;
                                if (appList.count > 0)
                                    appList.currentIndex = 0;
                            }

                            Keys.onReturnPressed: {
                                if (appList.count > 0 && appList.currentItem) {
                                    appList.currentItem.modelData.execute();
                                }
                            }

                            background: Rectangle {
                                color: "transparent"
                            }
                        }

                        MouseArea {
                            id: clearButton
                            width: 24
                            height: 24
                            visible: searchField.text.length > 0
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = "";
                                searchField.forceActiveFocus();
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: clearButton.pressed ? Colors.md3.surface_variant : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: Colors.md3.on_surface_variant
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Colors.md3.surface_bright
                    radius: 10
                    border.width: 1
                    border.color: Colors.md3.inverse_on_surface

                    // Filtered App Model
                    ScriptModel {
                        id: filteredModel
                        property string currentQuery: launcher.query

                        values: {
                            const q = currentQuery.trim().toLowerCase();
                            const allEntries = [...DesktopEntries.applications.values].filter(d => d.name).sort((a, b) => a.name.localeCompare(b.name));

                            if (q === "")
                                return allEntries;

                            return allEntries.filter(d => {
                                const name = (d.name || "").toLowerCase();
                                const comment = (d.comment || "").toLowerCase();
                                const keywords = (d.keywords || []).join(" ").toLowerCase();
                                const categories = (d.categories || []).join(" ").toLowerCase();
                                return name.includes(q) || comment.includes(q) || keywords.includes(q) || categories.includes(q);
                            });
                        }
                    }

                    // App List
                    ListView {
                        id: appList
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        model: filteredModel
                        currentIndex: 0
                        keyNavigationWraps: true

                        highlight: null
                        highlightMoveDuration: 0
                        highlightResizeDuration: 0

                        Text {
                            anchors.centerIn: parent
                            text: "No matching applications found"
                            color: Colors.md3.on_surface_variant
                            font.family: Config.bar.fontFamily
                            font.pixelSize: Config.bar.fontSize
                            visible: appList.count === 0
                        }

                        delegate: Item {
                            id: delegateItem
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            height: 48

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: 10
                                color: {
                                    if (index === appList.currentIndex)
                                        return Colors.md3.primary_container;
                                    else if (mouseArea.containsMouse)
                                        return Colors.md3.surface_container_high;
                                    else
                                        return "transparent";
                                }
                                opacity: {
                                    if (index === appList.currentIndex)
                                        return 0.6;
                                    else
                                        return 0.8;
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 80
                                    }
                                }
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 80
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appList.currentIndex = index;
                                    modelData.execute();
                                    launcher.visible = false;
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12

                                IconImage {
                                    source: Quickshell.iconPath(modelData.icon, true)
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        color: Colors.md3.on_surface
                                        font {
                                            family: Config.bar.fontFamily
                                            pixelSize: Config.bar.fontSize
                                            bold: true
                                        }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.comment || modelData.genericName || ""
                                        color: Colors.md3.on_surface_variant
                                        font {
                                            family: Config.bar.fontFamily
                                            pixelSize: Config.bar.fontSize - 2
                                        }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: Colors.md3.on_surface_variant
                                opacity: 0.3
                            }
                        }
                    }
                }
            }
        }

        Keys.onReturnPressed: {
            if (appList.count > 0 && appList.currentItem) {
                appList.currentItem.modelData.execute();
            }
        }
    }
}
