import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
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
    WlrLayershell.namespace: "qml-launcher"

    property color backgroundColor: Qt.rgba(0.157, 0.157, 0.157, 0.90)
    property color foregroundColor: "#d4be98"
    property color mutedColor: "#a89984"
    property color accentColor: "#d8a657"

    // Directory Models for NixOS & Flatpaks
    FolderListModel {
        id: nixSystemApplications
        folder: "file:///run/current-system/sw/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(nixSystemApplications)
    }

    FolderListModel {
        id: nixUserApplications
        folder: "file://" + Quickshell.env("HOME") + "/.nix-profile/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(nixUserApplications)
    }

    FolderListModel {
        id: nixPerUserApplications
        folder: "file:///etc/profiles/per-user/" + Quickshell.env("USER") + "/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(nixPerUserApplications)
    }

    FolderListModel {
        id: localApplications
        folder: "file://" + Quickshell.env("HOME") + "/.local/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(localApplications)
    }

    FolderListModel {
        id: flatpakApplications
        folder: "file://" + Quickshell.env("HOME") + "/.local/share/flatpak/exports/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(flatpakApplications)
    }

    FolderListModel {
        id: systemFlatpakApplications
        folder: "file:///var/lib/flatpak/exports/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) window.loadDesktopEntries(systemFlatpakApplications)
    }

    // Power Actions Pre-loaded
    ListModel {
        id: applications

        ListElement { name: "Lock"; exec: "swaylock" }
        ListElement { name: "Suspend"; exec: "systemctl suspend" }
        ListElement { name: "Logout"; exec: "niri msg action quit --skip-confirmation" }
        ListElement { name: "Reboot"; exec: "systemctl reboot" }
        ListElement { name: "Shutdown"; exec: "systemctl poweroff" }
    }

    ListModel {
        id: filteredApplications
    }

    function hasApplication(name, exec) {
        for (let i = 0; i < applications.count; ++i) {
            const item = applications.get(i)
            if (item.name === name || item.exec === exec) {
                return true
            }
        }
        return false
    }

    function loadDesktopEntries(folderModel) {
        for (let i = 0; i < folderModel.count; ++i) {
            const fileName = folderModel.get(i, "filePath")
            const fileUrl = fileName.startsWith("file://") ? fileName : "file://" + fileName
            const request = new XMLHttpRequest()
            request.open("GET", fileUrl, false)
            try {
                request.send()
            } catch (e) {
                continue
            }

            if (request.status !== 0 && request.status !== 200) {
                continue
            }

            let name = ""
            let exec = ""
            let hidden = false
            const lines = request.responseText.split(/\r?\n/)

            for (let line of lines) {
                line = line.trim()
                if (line === "Hidden=true" || line === "NoDisplay=true") {
                    hidden = true
                    break
                } else if (line.startsWith("Name=") && name === "") {
                    name = line.substring(5)
                } else if (line.startsWith("Exec=") && exec === "") {
                    exec = line.substring(5)
                               .replace(/@@[uUfF]?\s*/g, "")
                               .replace(/%[fFuUdiDnNickvm]/g, "")
                               .replace(/^\/usr\/bin\/flatpak/, "flatpak")
                               .trim()
                }
            }

            if (!hidden && name !== "" && exec !== "" && !hasApplication(name, exec)) {
                applications.append({ name: name, exec: exec })
            }
        }
        refreshResults()
    }

    // Alphabetical sort applied on search or reload
    function refreshResults() {
        filteredApplications.clear()
        const needle = search.text.trim().toLowerCase()
        let matched = []

        for (let i = 0; i < applications.count; ++i) {
            const item = applications.get(i)
            if (needle === "" || item.name.toLowerCase().includes(needle) || item.exec.toLowerCase().includes(needle)) {
                matched.push({ name: item.name, exec: item.exec })
            }
        }

        // Sort A to Z by item name
        matched.sort(function(a, b) {
            return a.name.localeCompare(b.name, undefined, { sensitivity: "base", numeric: true })
        })

        for (let i = 0; i < matched.length; ++i) {
            filteredApplications.append(matched[i])
        }

        if (filteredApplications.count > 0) {
            results.currentIndex = 0
        }
    }

    function launch(command) {
        const selected = command.trim()
        if (selected.length === 0) return

        Quickshell.execDetached(["sh", "-lc", selected])
        Qt.quit()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Qt.quit()

        Rectangle {
            id: launcher
            anchors.centerIn: parent
            width: 620
            height: 440
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
                spacing: 16

                Text {
                    text: "Applications"
                    color: window.accentColor
                    font.pixelSize: 22
                    font.bold: true
                }

                TextField {
                    id: search
                    width: parent.width
                    focus: true
                    placeholderText: "Search apps or type command…"
                    color: window.foregroundColor
                    placeholderTextColor: window.mutedColor
                    selectionColor: window.accentColor
                    selectedTextColor: "#282828"
                    font.pixelSize: 17
                    leftPadding: 14
                    rightPadding: 14
                    topPadding: 12
                    bottomPadding: 12
                    background: Rectangle {
                        radius: 8
                        color: "transparent"
                        border.width: 1
                        border.color: search.activeFocus ? window.accentColor : "#665c54"
                    }

                    onTextChanged: window.refreshResults()
                    Component.onCompleted: window.refreshResults()

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            Qt.quit()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            results.incrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            results.decrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (results.currentIndex >= 0 && filteredApplications.count > 0) {
                                window.launch(filteredApplications.get(results.currentIndex).exec)
                            } else {
                                window.launch(search.text)
                            }
                            event.accepted = true
                        }
                    }
                }

                ListView {
                    id: results
                    width: parent.width
                    height: parent.height - search.height - 54
                    clip: true
                    model: filteredApplications
                    currentIndex: 0
                    spacing: 4
                    keyNavigationWraps: true

                    delegate: Rectangle {
                        required property string name
                        required property string exec
                        width: results.width
                        height: 42
                        radius: 7
                        color: ListView.isCurrentItem ? "#3c3836" : "transparent"
                        border.width: ListView.isCurrentItem ? 1 : 0
                        border.color: window.accentColor

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: name
                            color: window.foregroundColor
                            font.pixelSize: 16
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: exec
                            color: window.mutedColor
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, parent.width * 0.4)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                results.currentIndex = index
                                window.launch(exec)
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: results.count === 0
                        text: "No matching application — press Enter to run command"
                        color: window.mutedColor
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
