// Forked from Decent Workspaces by TheTrueFerret, MIT. See NOTICE.md.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui
import "WindowModel.js" as Model

BarWidget {
  id: root
  moduleName: "io.github.zucram.app-workspaces"
  readonly property var options: Model.normalizeSettings(root.settings)
  readonly property color foreground: root.bar ? root.bar.barForeground : Color.foreground
  readonly property var barWindow: root.QsWindow.window
  readonly property string screenName: barWindow && barWindow.screen ? barWindow.screen.name : ""
  property var windows: []
  property var workspaces: []
  property string modelSignature: ""
  property bool opened: false
  property string saveError: ""
  property var popupAnchor: strip

  readonly property int activeId: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].name === root.screenName && monitors[i].activeWorkspace)
        return monitors[i].activeWorkspace.id
    }
    return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
  }
  property var activeSpecialIds: []
  property var knownScratchpads: ["special:scratchpad"]
  readonly property var visibleWorkspaces: Model.visibleWorkspaces(root.workspaces, root.screenName, root.activeId, root.options)
    .concat(Model.scratchpads(root.workspaces, root.activeSpecialIds, root.options, root.knownScratchpads))

  function refresh() {
    Hyprland.refreshMonitors()
    Hyprland.refreshWorkspaces()
    Hyprland.refreshToplevels()
    settle.restart()
  }
  function readModel() {
    var tops = Hyprland.toplevels.values
    var nextWindows = []
    for (var i = 0; i < tops.length; i++) {
      var t = tops[i]
      var ipc = t.lastIpcObject || ({})
      var address = String(t.address || ipc.address || "")
      if (!address) continue
      nextWindows.push({address: address,
        class: String(ipc["class"] || ipc.initialClass || ""),
        title: String(t.title || ipc.title || ""),
        at: ipc.at || [0, 0], floating: ipc.floating === true, pinned: ipc.pinned === true,
        workspaceId: t.workspace ? t.workspace.id : (ipc.workspace ? ipc.workspace.id : 0)})
    }
    var nextWorkspaces = []
    var ws = Hyprland.workspaces.values
    for (var j = 0; j < ws.length; j++) {
      var id = ws[j].id
      nextWorkspaces.push({id: id, name: String(ws[j].name || ""), monitor: ws[j].monitor ? ws[j].monitor.name : "",
        windows: nextWindows.filter(function(w) { return w.workspaceId === id }).length,
        urgent: ws[j].urgent === true})
    }
    var known = root.knownScratchpads.slice()
    nextWorkspaces.forEach(function(w) {
      if (w.id < 0 && known.indexOf(w.name) === -1) known.push(w.name)
    })
    if (known.length !== root.knownScratchpads.length) root.knownScratchpads = known
    var activeSpecial = []
    var monitors = Hyprland.monitors.values
    for (var m = 0; m < monitors.length; m++) {
      var special = (monitors[m].lastIpcObject || {}).specialWorkspace
      if (special && special.id < 0) activeSpecial.push(special.id)
    }
    if (JSON.stringify(activeSpecial) !== JSON.stringify(root.activeSpecialIds)) root.activeSpecialIds = activeSpecial
    var signature = JSON.stringify([nextWindows, nextWorkspaces])
    if (signature !== root.modelSignature) {
      root.modelSignature = signature
      root.windows = nextWindows
      root.workspaces = nextWorkspaces
    }
  }
  Component.onCompleted: root.refresh()
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = String(event.name)
      if (/window|workspace|focusedmon|monitoradded|monitorremoved|configreloaded|urgent/.test(name))
        refreshDelay.restart()
    }
  }
  Timer { id: refreshDelay; interval: 60; onTriggered: root.refresh() }
  Timer { id: settle; interval: 80; onTriggered: root.readModel() }
  // Geometry changes do not all have IPC events. Refresh without starting a
  // shell process; unchanged snapshots do not rebuild the window delegates.
  Timer { interval: 1000; repeat: true; running: root.visible; onTriggered: root.refresh() }

  function iconSource(icon) {
    var value = String(icon || "")
    if (!value) return ""
    if (value.indexOf("file://") === 0 || value.indexOf("image://icon/") === 0) return value
    if (value.charAt(0) === "/") return "file://" + value
    return Quickshell.iconPath(value, true)
  }
  function presentWindows(workspaceId) {
    var items = Model.windowsForWorkspace(root.windows, workspaceId, root.options)
    var entries = Array.prototype.slice.call(DesktopEntries.applications.values)
    return items.map(function(w) {
      var hint = w.class ? DesktopEntries.heuristicLookup(w.class) : null
      var entry = Model.resolveEntry(w.class, w.title, entries, hint, root.settings.iconOverrides || ({}))
      var name = entry ? entry.name : (w.class || w.title || "Window")
      return {address: w.address, class: w.class, title: w.title, name: name,
        floating: w.floating, pinned: w.pinned, source: root.iconSource(entry ? entry.icon : ""), initial: name.substring(0, 1).toUpperCase()}
    })
  }
  function toggleScratchpad(name) {
    if (!/^special(?::|$)/.test(name)) return
    Hyprland.dispatch('hl.dsp.workspace.toggle_special(' + Model.luaString(name.replace(/^special:?/, "")) + ')')
  }
  function focusWorkspace(id) {
    if (id < 0) {
      var ws = root.workspaces.filter(function(w) { return w.id === id })[0]
      if (ws) root.toggleScratchpad(ws.name)
      return
    }
    if (typeof id !== "number" || id <= 0) return
    Hyprland.dispatch('hl.dsp.focus({ workspace = "' + id + '" })')
  }
  function focusWindow(address, workspaceId) {
    var clean = String(address).replace(/^0x/, "")
    if (!/^[0-9a-fA-F]+$/.test(clean)) return
    if (workspaceId < 0 && root.activeSpecialIds.indexOf(workspaceId) === -1) root.focusWorkspace(workspaceId)
    Hyprland.dispatch('hl.dsp.focus({ window = "address:0x' + clean + '" })')
  }
  function scroll(delta) {
    Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (delta > 0 ? "e+1" : "e-1") + '" })')
  }
  function open() { root.popupAnchor = strip; root.opened = true }
  function close() { root.opened = false }
  function toggle() { root.opened ? root.close() : root.open() }
  // The bar and open KeyboardPanels forward clicks to registered WidgetButtons.
  // Register app buttons after their enclosing pill so the narrower hit wins.
  function syncClickTargets() {
    for (var i = 0; i < workspaceRepeater.count; i++) {
      var pill = workspaceRepeater.itemAt(i)
      if (pill) pill.syncClickTargets()
    }
  }
  onBarChanged: Qt.callLater(root.syncClickTargets)
  function setOption(key, value) {
    var normal = Model.normalizeSettings(({}))
    if (!Object.prototype.hasOwnProperty.call(normal, key)) return false
    var next = Object.assign({}, root.settings)
    next[key] = value
    next[key] = Model.normalizeSettings(next)[key]
    var host = root.bar ? root.bar.shell : null
    if (!host || typeof host.updateEntryInline !== "function") {
      root.saveError = "Settings could not be saved. Reopen the panel and try again."
      return false
    }
    host.updateEntryInline(root.moduleName, next)
    root.saveError = ""
    return true
  }
  function resetOptions() {
    var next = Object.assign({}, root.settings, Model.normalizeSettings(({})))
    if (root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName, next)
  }
  function status() {
    return JSON.stringify({version: "0.1.1", settingsOpen: root.opened, activeScratchpads: root.activeSpecialIds, options: root.options, screen: root.screenName, activeWorkspace: root.activeId,
      workspaces: root.visibleWorkspaces.map(function(ws) { return {id: ws.id, name: ws.name, windows: root.presentWindows(ws.id)} })})
  }
  IpcHandler {
    target: root.moduleName
    function open(): void { root.open() }
    function close(): void { root.close() }
    function refresh(): void { root.refresh() }
    function activateWorkspace(id: int): void { root.focusWorkspace(id) }
    function activateWindow(address: string): void {
      var clean = String(address).replace(/^0x/, "")
      var found = root.windows.filter(function(w) { return w.address.replace(/^0x/, "") === clean })[0]
      if (found) root.focusWindow(found.address, found.workspaceId)
    }
    function status(): string { return root.status() }
    function setOption(key: string, jsonValue: string): bool {
      try { return root.setOption(key, JSON.parse(jsonValue)) } catch (e) { return false }
    }
  }

  implicitWidth: root.vertical ? root.barSize : strip.implicitWidth
  implicitHeight: root.vertical ? strip.implicitHeight : root.barSize
  GridLayout {
    id: strip
    anchors.centerIn: parent
    columns: root.vertical ? 1 : Math.max(1, root.visibleWorkspaces.length)
    columnSpacing: 6
    rowSpacing: 6
    Repeater {
      id: workspaceRepeater
      model: root.visibleWorkspaces
      onItemAdded: Qt.callLater(root.syncClickTargets)
      Rectangle {
        id: pill
        required property var modelData
        readonly property bool special: /^special(?::|$)/.test(pill.modelData.name || "")
        readonly property bool active: pill.special ? root.activeSpecialIds.indexOf(pill.modelData.id) !== -1 : pill.modelData.id === root.activeId
        readonly property var apps: root.presentWindows(pill.modelData.id)
        readonly property var shownApps: !root.options.showIcons ? [] : root.options.maxIcons > 0 ? pill.apps.slice(0, root.options.maxIcons) : pill.apps
        readonly property int overflow: root.options.showIcons ? pill.apps.length - pill.shownApps.length : 0
        function syncClickTargets() {
          workspaceMouse.syncClickRegistration()
          for (var i = 0; i < appRepeater.count; i++) {
            var app = appRepeater.itemAt(i)
            if (app) app.clickTarget.syncClickRegistration()
          }
        }
        implicitWidth: root.vertical ? root.barSize - 4 : content.implicitWidth + 18
        implicitHeight: root.vertical ? content.implicitHeight + 12 : root.barSize - 6
        radius: Math.min(9, height / 2)
        color: pill.modelData.urgent ? Util.alpha(Color.urgent, 0.23)
          : pill.active ? Util.alpha(root.foreground, 0.15)
          : workspaceMouse.tooltipHovered ? Util.alpha(root.foreground, 0.07) : "transparent"
        border.width: pill.active ? 1 : 0
        border.color: Util.alpha(root.foreground, 0.13)
        WidgetButton {
          id: workspaceMouse
          anchors.fill: parent
          bar: root.bar
          labelVisible: false
          hasVisualContent: true
          onPressed: function(button) {
            if (button === Qt.RightButton) { root.popupAnchor = pill; root.opened = true }
            else if (button === Qt.LeftButton) {
              if (pill.special) root.toggleScratchpad(pill.modelData.name)
              else root.focusWorkspace(pill.modelData.id)
            }
          }
          onWheelMoved: function(delta) { root.scroll(delta) }
        }
        PanelToolTip {
          visible: workspaceMouse.tooltipHovered && !root.opened
          text: pill.special ? "Scratchpad: " + pill.modelData.name.replace(/^special:?/, "") : "Workspace " + pill.modelData.id
        }
        GridLayout {
          id: content
          anchors.centerIn: parent
          columns: root.vertical ? 1 : 100
          columnSpacing: root.options.iconGap
          rowSpacing: root.options.iconGap
          Text {
            visible: pill.special || root.options.showNumbers || pill.shownApps.length === 0
            textFormat: Text.PlainText
            text: pill.special ? (pill.modelData.name === "special:scratchpad" || pill.modelData.name === "special" ? "S" : pill.modelData.name.replace(/^special:/, "")) : String(pill.modelData.id)
            elide: Text.ElideRight
            Layout.maximumWidth: root.vertical ? root.barSize - 10 : 80
            color: Util.alpha(root.foreground, pill.active ? 1 : 0.65)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: 12
            font.weight: pill.active ? Font.DemiBold : Font.Normal
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: root.vertical || pill.shownApps.length === 0 ? 0 : 2
          }
          Repeater {
            id: appRepeater
            model: pill.shownApps
            onItemAdded: Qt.callLater(root.syncClickTargets)
            Item {
              id: app
              required property var modelData
              property alias clickTarget: appMouse
              implicitWidth: root.options.iconSize
              implicitHeight: root.options.iconSize
              Layout.alignment: Qt.AlignCenter
              Rectangle {
                anchors.fill: parent
                radius: 4
                color: Util.alpha(root.foreground, 0.10)
                visible: appImage.status !== Image.Ready
                Text {
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: app.modelData.initial
                  color: root.foreground
                  font.family: Style.font.family
                  font.pixelSize: Math.round(root.options.iconSize * 0.62)
                  font.bold: true
                }
              }
              Image {
                id: appImage
                anchors.fill: parent
                source: app.modelData.source
                sourceSize.width: root.options.iconSize * 2
                sourceSize.height: root.options.iconSize * 2
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
                visible: status === Image.Ready
              }
              Rectangle {
                visible: root.options.markFloating && app.modelData.floating
                width: 8; height: 7; radius: 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -2
                anchors.bottomMargin: -2
                color: root.bar ? root.bar.background : Color.background
                border.width: 1
                border.color: root.foreground
              }
              WidgetButton {
                id: appMouse
                anchors.fill: parent
                bar: root.bar
                labelVisible: false
                hasVisualContent: true
                onPressed: function(button) {
                  if (button === Qt.RightButton) { root.popupAnchor = pill; root.opened = true }
                  else if (button === Qt.LeftButton) root.focusWindow(app.modelData.address, pill.modelData.id)
                }
                onWheelMoved: function(delta) { root.scroll(delta) }
              }
              PanelToolTip {
                visible: appMouse.tooltipHovered && !root.opened
                text: app.modelData.name + (app.modelData.floating ? " · Floating" : "") + (app.modelData.pinned ? " · Pinned" : "") + (app.modelData.title && app.modelData.title !== app.modelData.name ? "\n" + app.modelData.title.substring(0, 180) : "")
              }
            }
          }
          Text {
            visible: pill.overflow > 0
            textFormat: Text.PlainText
            text: "+" + pill.overflow
            font.pixelSize: 11
            font.family: Style.font.family
            color: Util.alpha(root.foreground, 0.7)
            Layout.alignment: Qt.AlignCenter
          }
        }
      }
    }
  }
  SettingsPanel { widget: root }
}
