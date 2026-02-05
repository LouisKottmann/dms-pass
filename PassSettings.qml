import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "dmsPass"

    StyledText {
        width: parent.width
        text: "Pass Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Fuzzy-search Pass entries and copy them to the clipboard."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
