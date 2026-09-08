.pragma library

// SPDX-License-Identifier: MIT
// Pure presentation helpers. Pass arrays, not QML ObjectModels. Entry fields:
// id, name, icon, startupClass, execString, noDisplay. Hint is an optional
// DesktopEntries.heuristicLookup(class) result. Overrides are exact mappings
// {"Beeper": "beeper", "title:LibrePods": "me.kavishdevar.librepods"}.
// Values are desktop IDs, never commands or arbitrary icon paths. No cache:
// callers must recompute when DesktopEntries.applications changes.
function text(value) {
    return typeof value === "string" ? value.trim() : "";
}

function key(value) {
    return text(value).toLowerCase().replace(/\.desktop$/, "");
}

function hasIcon(entry) {
    return entry && text(entry.icon) !== "";
}

function same(a, b) {
    return key(a) !== "" && key(a) === key(b);
}

// Chromium encodes a URL's path separators as underscores in app classes.
// Compare the complete host/path so two apps on one host remain distinct.
function webClass(execString) {
    var match = text(execString).match(/https?:\/\/([^\s"']+)/i);
    if (!match) return "";
    return match[1].replace(/\/$/, "").toLowerCase().replace(/\//g, "_");
}

function resolveEntry(cls, title, entries, hint, overrides) {
    cls = text(cls);
    title = text(title);
    entries = Array.isArray(entries) ? entries : [];
    overrides = overrides && typeof overrides === "object" ? overrides : {};
    var override = "";
    if (Object.prototype.hasOwnProperty.call(overrides, cls))
        override = text(overrides[cls]);
    if (!override && Object.prototype.hasOwnProperty.call(overrides, "title:" + title))
        override = text(overrides["title:" + title]);
    var pwa = cls.match(/^(?:chrome|chromium|helium|brave|msedge)-(.+?)(?:__|_)-[^\s]+$/i);
    var pwaKey = pwa ? pwa[1].toLowerCase().replace(/_$/, "") : "";
    var best = null;
    var bestScore = 0;
    for (var i = 0; i < entries.length; i++) {
        var entry = entries[i];
        if (!hasIcon(entry)) continue;
        var score = 0;
        if (override && same(override, entry.id)) score = 100;
        else if (same(cls, entry.startupClass)) score = 90;
        else if (same(cls, entry.id)) score = 85;
        else if (pwaKey && pwaKey === webClass(entry.execString)) score = 80;
        else if (same(cls, entry.name)) score = 70;
        else if (!cls && (same(title, entry.name) || same(title, entry.id))) score = 65;
        else if (hint && same(hint.name, entry.name)) score = 50;
        // Prefer a visible launcher only within the same matching tier.
        if (score && !entry.noDisplay) score += 1;
        if (score > bestScore) {
            best = entry;
            bestScore = score;
        }
    }
    return best || (hasIcon(hint) ? hint : null);
}

// Input windows have address, class, title and at: [x, y]. Return original
// objects in screen order. Grouping keeps the leftmost window of each class,
// or exact title for a classless window. Unknown windows remain independent.
function orderedWindows(windows, groupApps) {
    var rows = Array.isArray(windows) ? windows.filter(function (w) { return !!w; }) : [];
    function coordinate(w, axis) {
        var n = w.at && w.at[axis];
        return typeof n === "number" && isFinite(n) ? n : 0;
    }
    rows = rows.map(function (w, index) { return { window: w, index: index }; });
    rows.sort(function (a, b) {
        var delta = coordinate(a.window, 0) - coordinate(b.window, 0)
            || coordinate(a.window, 1) - coordinate(b.window, 1);
        if (delta) return delta;
        var aa = text(a.window.address), ba = text(b.window.address);
        return aa < ba ? -1 : aa > ba ? 1 : a.index - b.index;
    });
    var seen = Object.create(null);
    return rows.filter(function (row) {
        if (!groupApps) return true;
        var w = row.window;
        var identity = text(w.class) ? "class:" + key(w.class)
            : text(w.title) ? "title:" + text(w.title) : "row:" + row.index;
        if (seen[identity]) return false;
        seen[identity] = true;
        return true;
    }).map(function (row) { return row.window; });
}

function normalizeSettings(raw) {
    raw = raw && typeof raw === "object" ? raw : {};
    function number(name, fallback, min, max) {
        var value = raw[name];
        if (typeof value !== "number" || !isFinite(value)) return fallback;
        return Math.max(min, Math.min(max, Math.round(value)));
    }
    function boolean(name, fallback) {
        return typeof raw[name] === "boolean" ? raw[name] : fallback;
    }
    return {
        iconSize: number("iconSize", 20, 12, 28),
        iconGap: number("iconGap", 6, 2, 12),
        maxIcons: number("maxIcons", 0, 0, 20),
        showNumbers: boolean("showNumbers", true),
        showIcons: boolean("showIcons", true),
        showEmpty: boolean("showEmpty", false),
        perMonitor: boolean("perMonitor", true),
        groupApps: boolean("groupApps", false),
        showScratchpad: boolean("showScratchpad", true),
        showEmptyScratchpad: boolean("showEmptyScratchpad", false),
        showFloating: boolean("showFloating", true),
        markFloating: boolean("markFloating", true)
    };
}

// Rows contain numeric id, monitor name and numeric windows count. Active ID
// is the workspace active on this bar's monitor. Empty rows come from live
// state; this function never synthesizes workspace numbers or caps them at 10.
function visibleWorkspaces(workspaces, monitorName, activeId, settings) {
    settings = normalizeSettings(settings);
    return (Array.isArray(workspaces) ? workspaces : []).filter(function (w) {
        return w && typeof w.id === "number" && isFinite(w.id) && w.id > 0
            && Math.floor(w.id) === w.id
            && (!settings.perMonitor || w.monitor === monitorName)
            && (settings.showEmpty || w.id === activeId || w.windows > 0);
    }).sort(function (a, b) { return a.id - b.id; });
}

// Special workspaces are portable across monitors. Keep occupied scratchpads
// reachable even when their last monitor differs from this bar's monitor.
function scratchpads(workspaces, activeIds, settings, knownNames) {
    settings = normalizeSettings(settings);
    if (!settings.showScratchpad) return [];
    var result = (Array.isArray(workspaces) ? workspaces : []).filter(function(w) {
        return w && w.id < 0 && /^special(?::|$)/.test(w.name || "")
            && (w.windows > 0 || settings.showEmptyScratchpad || activeIds.indexOf(w.id) !== -1);
    });
    if (settings.showEmptyScratchpad) {
        (knownNames || ["special:scratchpad"]).forEach(function(name) {
            if (/^special(?::|$)/.test(name) && !result.some(function(w) { return w.name === name; }))
                result.push({id: 0, name: name, windows: 0, placeholder: true});
        });
    }
    return result.sort(function(a, b) { return a.name.localeCompare(b.name); });
}

function windowsForWorkspace(windows, workspaceId, settings) {
    settings = normalizeSettings(settings);
    return orderedWindows(windows.filter(function(w) {
        return w.workspaceId === workspaceId && (settings.showFloating || !w.floating);
    }), settings.groupApps);
}

// Escape a literal for Lua IPC, including control characters. Window classes,
// names and titles must never become executable Lua fragments.
function luaString(value) {
    return '"' + String(value).replace(/[\\"\x00-\x1f\x7f]/g, function(c) {
        if (c === '"' || c === "\\") return "\\" + c;
        return "\\" + ("00" + c.charCodeAt(0)).slice(-3);
    }) + '"';
}
