{ pkgs, ... }:

{
  # Directly overwrite DMS's core system logo component
  xdg.configFile."DankMaterialShell/Widgets/SystemLogo.qml".text = ''
    import QtQuick
    import QtQuick.Layouts
    import QtQuick.Effects
    import Quickshell
    import Quickshell.Widgets
    import qs.Common
    import qs.Widgets

    Item {
        id: root

        // Match DMS's internal core property expectations
        property string colorOverride: ""
        property real brightnessOverride: 0.5
        property real contrastOverride: 1
        readonly property bool hasColorOverride: colorOverride !== ""

        // Hardcode NixOS instantly so it bypasses the buggy boot-loop script
        property bool useNerdFont: true
        property string nerdFontIcon: "nixos"

        // Explicitly declare structural sizing boundaries to match the bar profile
        implicitWidth: Theme.barHeight || 32
        implicitHeight: Theme.barHeight || 32
        width: implicitWidth
        height: implicitHeight

        IconImage {
            id: iconImage
            anchors.fill: parent
            visible: !root.useNerdFont
            smooth: true
            asynchronous: false
            layer.enabled: hasColorOverride

            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: colorOverride
                brightness: brightnessOverride
                contrast: contrastOverride
            }
        }

        DankNFIcon {
            id: nfIcon
            anchors.centerIn: parent
            visible: root.useNerdFont
            name: root.nerdFontIcon
            size: Math.min(root.width, root.height) * 0.8
            color: hasColorOverride ? colorOverride : Theme.surfaceText
        }
    }
  '';
}

