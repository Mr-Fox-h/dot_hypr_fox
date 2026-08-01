import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Hyprland

import "config.js" as Config
import "Colors.qml"

FloatingWindow {
    id: root
    visible: false
    width: 1000
    height: 550
    color: Colors.md3.surface_container_low
    title: "Theme Wallpaper Switcher"
    maximumSize: Qt.size(1000, 550)
    minimumSize: Qt.size(1000, 550)

    // Close on Escape
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.visible = false;
            event.accepted = true;
        }
    }

    // IPC to toggle window from outside
    IpcHandler {
        target: "wallpaper"
        function toggle() {
            root.visible = !root.visible;
        }
    }

    // ----- Data Model -----
    ListModel {
        id: imageModel
    }

    property bool loading: false
    property string selectedPath: ""
    property bool darkMode: true

    // ----- Process Declarations -----
    Process {
        id: findProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var path = lines[i].trim();
                    if (!path)
                        continue;

                    var rel = path;
                    if (rel.startsWith("~/Pictures/")) {
                        rel = rel.substring(11);
                    } else if (rel.includes("/Pictures/")) {
                        rel = rel.substring(rel.indexOf("/Pictures/") + 10);
                    }

                    imageModel.append({
                        "path": path,
                        "filename": rel
                    });
                }

                loading = false;
                if (imageModel.count === 0) {
                    statusText.text = "No images found in ~/Pictures";
                } else {
                    statusText.text = `Loaded ${imageModel.count} images`;
                }
            }
        }
        onExited: function (exitCode, exitStatus) {
            if (exitCode !== 0 && imageModel.count === 0) {
                loading = false;
                statusText.text = "Error scanning directory.";
            }
        }
    }

    Process {
        id: matugenProcess
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: function (exitCode, exitStatus) {
            if (exitCode === 0) {
                statusText.text = `Applied: ${selectedPath}`;
                closeTimer.start();
            } else {
                statusText.text = "Error: matugen failed (code " + exitCode + ")";
                applyButton.enabled = true;
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 800
        repeat: false
        onTriggered: root.visible = false
    }

    // ----- Main Layout -----
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // Header
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "<b>Theme Wallpaper Switcher</b>"
            color: Colors.md3.primary
            font {
                family: Config.bar.fontFamily
                pixelSize: Config.bar.fontSize + 8
            }
        }

        // Grid of wallpapers
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.md3.surface_container
            radius: 10
            border.width: 1
            border.color: Colors.md3.surface_container_high
            clip: true

            Flickable {
                id: flickable
                anchors.fill: parent
                anchors.margins: 10
                contentWidth: width
                contentHeight: gridLayout.implicitHeight
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                // Grid provides true alignment and spacing control
                Grid {
                    id: gridLayout
                    // Center the entire grid block horizontally
                    width: implicitWidth
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Dynamically calculate columns based on available width
                    columns: Math.max(1, Math.floor(flickable.width / (210 + 12)))
                    spacing: 12 // Exact, consistent gap between all images

                    Repeater {
                        model: imageModel
                        delegate: wallpaperDelegate
                    }
                }
            }

            // Delegate for each wallpaper
            Component {
                id: wallpaperDelegate
                Item {
                    // Fixed dimensions for the Grid to calculate layout perfectly
                    width: 210
                    height: 180

                    Rectangle {
                        anchors.centerIn: parent
                        width: 210
                        height: 150
                        radius: 12

                        // CRITICAL: This ensures the Image inside respects the rounded corners.
                        // It does NOT clip the Rectangle's own border or background when it scales.
                        clip: true

                        // 1. Thicker border and background
                        color: model.path === root.selectedPath ? Colors.md3.primary_container : "transparent"
                        border.width: model.path === root.selectedPath ? 4 : 0
                        border.color: Colors.md3.primary

                        // 2. Smooth "pop" animation when selected
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                        scale: model.path === root.selectedPath ? 1.08 : 1.0

                        Image {
                            anchors.fill: parent

                            // Inset the image slightly so the Rectangle's border and background
                            // color are visible and not covered by the image.
                            anchors.margins: model.path === root.selectedPath ? 4 : 0

                            // Smoothly animate the margin change to match the scale pop
                            Behavior on anchors.margins {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }

                            source: "file://" + encodeURI(model.path)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true

                            // Optional: dim unselected images slightly to make the selected one pop more
                            opacity: model.path === root.selectedPath ? 1.0 : 0.85
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selectedPath = model.path;
                                applyButton.enabled = true;
                            }
                        }
                    }
                }
            }

            // Loading overlay
            Rectangle {
                id: loadingOverlay
                anchors.fill: parent
                color: Colors.md3.surface_container
                opacity: loading ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 15

                    BusyIndicator {
                        anchors.horizontalCenter: parent.horizontalCenter
                        running: loading
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: loading ? "Loading thumbnails..." : ""
                        color: Colors.md3.on_surface
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize
                    }
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: imageModel.count === 0 && !loading ? "No images found in ~/Pictures" : ""
                color: Colors.md3.on_surface_variant
                font.family: Config.bar.fontFamily
                font.pixelSize: Config.bar.fontSize
                visible: imageModel.count === 0 && !loading
            }
        }

        // Status bar
        Text {
            id: statusText
            Layout.fillWidth: true
            text: "Ready"
            color: Colors.md3.on_surface_variant
            font.family: Config.bar.fontFamily
            font.pixelSize: Config.bar.fontSize - 2
        }

        // Buttons row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            CheckBox {
                id: darkCheck
                text: "Dark Mode"
                checked: true
                font.family: Config.bar.fontFamily
                font.pixelSize: Config.bar.fontSize
                onCheckedChanged: darkMode = checked

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: Colors.md3.on_surface
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20
                }
                indicator: Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    border.width: 2
                    border.color: parent.checked ? Colors.md3.primary : Colors.md3.outline
                    color: parent.checked ? Colors.md3.primary : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: ""
                        color: Colors.md3.on_primary
                        font.pixelSize: 14
                        anchors.centerIn: parent
                        visible: parent.parent.checked
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 150
                height: 35
                radius: 10
                color: applyButton.containsMouse ? Colors.md3.surface_bright : Colors.md3.inverse_on_surface

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Applying Selected"
                    color: applyButton.containsMouse ? Colors.md3.primary_fixed : Colors.md3.primary
                    font {
                        family: Config.bar.fontFamily
                        pixelSize: Config.bar.fontSize
                    }
                }

                MouseArea {
                    id: applyButton
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: applyWallpaper()
                }
            }

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

    // ----- Helper Functions -----
    function applyWallpaper() {
        if (!selectedPath)
            return;
        var mode = darkMode ? "dark" : "light";
        statusText.text = `Applying: ${selectedPath} (mode: ${mode})...`;
        applyButton.enabled = false;

        matugenProcess.command = ["sh", "-c", `matugen image "${selectedPath}" -m ${mode} --source-color-index 0`];
        matugenProcess.running = true;
    }

    function loadImages() {
        if (loading)
            return;
        loading = true;
        imageModel.clear();
        statusText.text = "Scanning for images...";

        findProcess.command = ["sh", "-c", "find ~/Pictures -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.gif' \\) 2>/dev/null"];
        findProcess.running = true;
    }

    onVisibleChanged: {
        if (visible && imageModel.count === 0) {
            loadImages();
        }
    }

    Component.onCompleted: {
        if (visible)
            loadImages();
    }
}
