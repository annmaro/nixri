{ ... }:

{
  xdg.configFile."qml-keybinds/shell.qml".text = ''
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: window

    visible: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qml-keybinds"

    property color backgroundColor: Qt.rgba(0.157, 0.157, 0.157, 0.90)
    property color foregroundColor: "#d4be98"
    property color mutedColor: "#a89984"
    property color accentColor: "#d8a657"
    property color badgeColor: "#3c3836"

    ListModel {
        id: allBinds

        // Applications & System
        ListElement { key: "Mod + Return"; desc: "Open Ghostty terminal"; cat: "Launch" }
        ListElement { key: "Mod + T"; desc: "Open Footclient terminal"; cat: "Launch" }
        ListElement { key: "Ctrl + T"; desc: "Open Tmux Sessionizer"; cat: "Launch" }
        ListElement { key: "Mod + C"; desc: "Open Editor"; cat: "Launch" }
        ListElement { key: "Mod + F"; desc: "Open Firefox"; cat: "Launch" }
        ListElement { key: "Mod + A"; desc: "Open Antigravity"; cat: "Launch" }
        ListElement { key: "Mod + G"; desc: "Game Launcher"; cat: "Launch" }
        ListElement { key: "Mod + P"; desc: "Open KeePassXC"; cat: "Launch" }
        ListElement { key: "Mod + Shift + S"; desc: "Open Spotify"; cat: "Launch" }
        ListElement { key: "Mod + Shift + Y"; desc: "Open YouTube Music"; cat: "Launch" }
        ListElement { key: "Mod + Shift + T"; desc: "Restart Thunar Daemon"; cat: "System" }
        ListElement { key: "Mod + Ctrl + T"; desc: "Open Tor Browser"; cat: "Launch" }

        // Window & Layout Actions
        ListElement { key: "Alt + F4 / Ctrl + Q"; desc: "Close window"; cat: "Windows" }
        ListElement { key: "Alt + Return"; desc: "Toggle fullscreen window"; cat: "Windows" }
        ListElement { key: "Mod + Shift + V"; desc: "Toggle floating window"; cat: "Windows" }
        ListElement { key: "Mod + M"; desc: "Maximize column"; cat: "Windows" }
        ListElement { key: "Mod + R"; desc: "Cycle column preset width"; cat: "Windows" }
        ListElement { key: "Mod + O"; desc: "Toggle overview"; cat: "Windows" }
        ListElement { key: "Mod + = / -"; desc: "Adjust column width (+/- 10%)"; cat: "Windows" }
        ListElement { key: "Mod + Shift + = / -"; desc: "Adjust window height (+/- 10%)"; cat: "Windows" }

        // Navigation
        ListElement { key: "Mod + Left / H"; desc: "Focus column left"; cat: "Navigation" }
        ListElement { key: "Mod + Right / L"; desc: "Focus column right"; cat: "Navigation" }
        ListElement { key: "Mod + Up / Down"; desc: "Focus window or workspace up/down"; cat: "Navigation" }
        ListElement { key: "Mod + Ctrl + Left / Right"; desc: "Move column left / right"; cat: "Navigation" }
        ListElement { key: "Mod + Ctrl + J / K"; desc: "Move column to workspace down / up"; cat: "Navigation" }
        ListElement { key: "Mod + 1 .. 3"; desc: "Switch to workspace 1 - 3"; cat: "Workspaces" }
        ListElement { key: "Mod + Shift + 1 .. 5"; desc: "Move column to workspace 1 - 5"; cat: "Workspaces" }

        // Utilities & Media
        ListElement { key: "Mod + K"; desc: "Toggle Keybinds Overview"; cat: "System" }
        ListElement { key: "Mod + Ctrl + P"; desc: "Screenshot selection (Satty)"; cat: "Media" }
        ListElement { key: "Mod + Shift + R"; desc: "Screen recording"; cat: "Media" }
        ListElement { key: "Mod + Escape"; desc: "Stop screen recording"; cat: "Media" }
        ListElement { key: "Mod + Ctrl + C"; desc: "Color picker (Hyprpicker)"; cat: "Utilities" }
        ListElement { key: "Mod + F9 / F10"; desc: "Toggle wlsunset blue light filter"; cat: "Utilities" }
        ListElement { key: "Mod + Alt + L"; desc: "Lock screen (Swaylock)"; cat: "System" }
        ListElement { key: "Ctrl + Alt + Del"; desc: "System monitor (btop)"; cat: "System" }
        ListElement { key: "Alt + S"; desc: "Restart desktop bar"; cat: "System" }
    }

    ListModel {
        id: filteredBinds
    }

    function filterEntries() {
        filteredBinds.clear()
        const query = search.text.trim().toLowerCase()
        for (let i = 0; i < allBinds.count; ++i) {
            const item = allBinds.get(i)
            if (query === "" ||
                item.key.toLowerCase().includes(query) ||
                item.desc.toLowerCase().includes(query) ||
                item.cat.toLowerCase().includes(query)) {
                filteredBinds.append(item)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Qt.quit()

        Rectangle {
            anchors.centerIn: parent
            width: 780
            height: 560
            radius: 14
            color: window.backgroundColor
            border.width: 2
            border.color: window.accentColor

            MouseArea {
                anchors.fill: parent
                onClicked: mouse.accepted = true
            }

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                Row {
                    width: parent.width
                    Text {
                        text: "Keybinding Cheatsheet"
                        color: window.accentColor
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Item { width: 1; height: 1 }
                }

                TextField {
                    id: search
                    width: parent.width
                    focus: true
                    placeholderText: "Search key, action, or category (e.g., 'workspace', 'mod+c')…"
                    color: window.foregroundColor
                    placeholderTextColor: window.mutedColor
                    selectionColor: window.accentColor
                    selectedTextColor: "#282828"
                    font.pixelSize: 15
                    leftPadding: 14
                    rightPadding: 14
                    topPadding: 10
                    bottomPadding: 10
                    background: Rectangle {
                        radius: 8
                        color: "transparent"
                        border.width: 1
                        border.color: search.activeFocus ? window.accentColor : "#665c54"
                    }

                    onTextChanged: window.filterEntries()
                    Component.onCompleted: window.filterEntries()

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            Qt.quit()
                            event.accepted = true
                        }
                    }
                }

                ListView {
                    id: bindList
                    width: parent.width
                    height: parent.height - search.height - 62
                    clip: true
                    model: filteredBinds
                    spacing: 6

                    delegate: Rectangle {
                        required property string key
                        required property string desc
                        required property string cat

                        width: bindList.width
                        height: 38
                        radius: 6
                        color: "#32302f"

                        Rectangle {
                            id: catPill
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            height: 22
                            width: catText.implicitWidth + 12
                            radius: 4
                            color: "#3c3836"

                            Text {
                                id: catText
                                anchors.centerIn: parent
                                text: cat
                                color: window.mutedColor
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Text {
                            anchors.left: catPill.right
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: desc
                            color: window.foregroundColor
                            font.pixelSize: 14
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            height: 24
                            width: keyText.implicitWidth + 14
                            radius: 4
                            color: window.badgeColor
                            border.width: 1
                            border.color: window.accentColor

                            Text {
                                id: keyText
                                anchors.centerIn: parent
                                text: key
                                color: window.accentColor
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
  '';
}
