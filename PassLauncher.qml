import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Common

Item {
    id: root

    // Required properties
    property var pluginService: null
    property string pluginId: "dms-pass"
    property string trigger: "pass"
    
    // Internal properties
    property var _entries: []
    property bool _indexing: false

    // Required signal
    signal itemsChanged()

    Component.onCompleted: {
        if (pluginService) {
            trigger = pluginService.loadPluginData(pluginId, "trigger", "pass")
        }
        reloadEntries()
    }

    onTriggerChanged: {
        if (pluginService) {
            pluginService.savePluginData(pluginId, "trigger", trigger)
        }
    }

    function reloadEntries() {
        if (_indexing) return
        _indexing = true
        _entries = []
        indexProcessComp.createObject(root).running = true
    }

    function getItems(query) {
        const results = []
        
        if (!_entries.length) {
             return results
        }
        
        const q = (query || "").toLowerCase().trim()
        const limit = 50

        for (let i = 0; i < _entries.length; i++) {
            const entry = _entries[i]
            if (!q || entry.toLowerCase().includes(q)) {
                results.push({
                    name: entry,
                    icon: "material:vpn_key",
                    comment: "Pass: " + entry,
                    action: "pass:" + entry,
                    // Category MUST match the Plugin Name ("Pass") for correct section grouping
                    categories: ["Pass"],
                    keywords: ["pass", entry]
                })
            }
        }
        
        results.sort((a, b) => {
            const lenDiff = a.name.length - b.name.length
            if (lenDiff !== 0) return lenDiff
            return a.name.localeCompare(b.name)
        })
        
        return results.slice(0, limit)
    }

    function executeItem(item) {
        if (!item || !item.action) return
        
        const action = item.action

        if (action.startsWith("pass:")) {
            const entry = action.substring(5)
            const cmd = "pass -c " + shellQuote(entry)
            
            console.info("[dms-pass] Executing command: " + cmd)
            
            Quickshell.execDetached(["sh", "-c", cmd])
            
            if (typeof ToastService !== "undefined") {
                ToastService.showInfo("Pass", "Copying " + entry)
            }
        }
    }

    function getContextMenuActions(item) {
        if (!item) return []
        return [
             {
                icon: "content_copy",
                text: "Copy Password",
                action: () => executeItem(item)
            }
        ]
    }

    function shellQuote(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'"
    }

    property Component indexProcessComp: Component {
        Process {
            command: ["sh", "-c", "cd \"${PASSWORD_STORE_DIR:-$HOME/.password-store}\" && find . -name '*.gpg' -type f"]
            stdout: SplitParser {
                onRead: function(line) {
                    let s = line.trim()
                    if (!s) return
                    if (s.startsWith("./")) s = s.substring(2)
                    if (s.endsWith(".gpg")) s = s.substring(0, s.length - 4)
                    root._entries.push(s)
                }
            }
            onExited: function(code) {
                console.info("[dms-pass] Indexing finished with code " + code + ". Found " + root._entries.length + " entries.")
                root._indexing = false
                root.itemsChanged()
                destroy()
            }
        }
    }
}
