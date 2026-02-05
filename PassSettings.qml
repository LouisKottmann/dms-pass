import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "dms-pass"

    StyledText {
        width: parent.width
        text: "Pass Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Pass uses the standard GPG configuration. Ensure your gpg-agent is configured with a pinentry program (like pinentry-gnome3 or pinentry-qt) to allow unlocking your key from the GUI."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
