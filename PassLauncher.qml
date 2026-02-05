import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Common

import "fuzzy.js" as Fuzzy

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
        
        // If no query, just return everything (or a subset)
        if (!query || query.trim().length === 0) {
            // Just show first 50 alphabetically
             for (let i = 0; i < Math.min(50, _entries.length); i++) {
                results.push(formatEntry(_entries[i]))
            }
            return results
        }

        const scored = []
        for (let i = 0; i < _entries.length; i++) {
            const entry = _entries[i]
            const score = Fuzzy.fuzzyScore(query, entry)
            if (score !== null) {
                scored.push({ entry: entry, score: score })
            }
        }
        
        // Sort by score (descending)
        scored.sort((a, b) => b.score - a.score)
        
        const limit = 50
        for (let i = 0; i < Math.min(limit, scored.length); i++) {
            results.push(formatEntry(scored[i].entry))
        }
        
        return results
    }
    
    function formatEntry(entry) {
        // Example entry: "social/facebook/myuser"
        // Title: "social/facebook"
        // Comment: "myuser"
        // If it's just "facebook", Title="facebook", Comment=""
        
        const lastSlash = entry.lastIndexOf('/')
        let name = entry
        let comment = ""
        
        if (lastSlash !== -1) {
            name = entry.substring(0, lastSlash)
            comment = entry.substring(lastSlash + 1)
        } else {
             // If no folder, usually it's "service" or "service.com"
             // Often people do "service/username".
             // If just "service", name="service", comment=""
        }

        return {
            name: name,
            icon: "material:vpn_key",
            comment: comment,
            action: "pass:" + entry,
            categories: ["Pass"],
            keywords: ["pass", entry]
        }
    }

    function executeItem(item) {
        if (!item || !item.action) return
        
        const action = item.action

        if (action.startsWith("pass:")) {
            const entry = action.substring(5)
            const cmd = "pass -c " + shellQuote(entry)
            
            Quickshell.execDetached(["sh", "-c", cmd])
            
            if (typeof ToastService !== "undefined") {
                ToastService.showInfo("Pass: " + entry + " copied to clipboard")
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
                // Initial sort is nice for the "no query" state
                root._entries.sort()
                root._indexing = false
                root.itemsChanged()
                destroy()
            }
        }
    }
}
