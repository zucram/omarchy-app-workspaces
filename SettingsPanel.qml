// App Workspaces settings. Uses Omarchy's native themed panel components.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

KeyboardPanel {
  id: panel
  required property var widget
  property string page: "appearance"
  anchorItem: widget.popupAnchor
  owner: widget
  bar: widget.bar
  open: widget.opened
  contentWidth: panel.fittedContentWidth(400)
  contentHeight: panel.fittedContentHeight(content.implicitHeight, 690)
  focusTarget: body

  Item {
    id: body
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: panel.widget.close()
    Flickable {
      id: scroller
      anchors.fill: parent
      contentWidth: width
      contentHeight: content.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Column {
        id: content
        width: parent.width
        spacing: 12
        RowLayout {
          width: parent.width
          Column {
            Layout.fillWidth: true
            spacing: 4
            Text {
              text: "App Workspaces"
              textFormat: Text.PlainText
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: 20
              font.bold: true
            }
            Text {
              text: "Your windows, in order."
              textFormat: Text.PlainText
              color: Util.alpha(Color.foreground, 0.65)
              font.family: Style.font.family
              font.pixelSize: 12
            }
          }
          Button { text: "Done"; focusable: true; onClicked: panel.widget.close() }
        }
        RowLayout {
          width: parent.width
          Button { text: "Appearance"; focusable: true; selected: panel.page === "appearance"; Layout.fillWidth: true; onClicked: { panel.page = "appearance"; scroller.contentY = 0 } }
          Button { text: "Windows"; focusable: true; selected: panel.page === "windows"; Layout.fillWidth: true; onClicked: { panel.page = "windows"; scroller.contentY = 0 } }
        }
        Rectangle { width: parent.width; height: 1; color: Util.alpha(Color.foreground, 0.12) }
        Column {
          visible: panel.page === "appearance"
          width: parent.width
          spacing: 8
          RowLayout {
            width: parent.width
            Text { text: "Icon size"; textFormat: Text.PlainText; color: Color.foreground; font.family: Style.font.family; font.pixelSize: 13; Layout.fillWidth: true }
            Text { text: panel.widget.options.iconSize + " px"; textFormat: Text.PlainText; color: Util.alpha(Color.foreground, 0.65); font.family: Style.font.family; font.pixelSize: 12 }
          }
          PanelSlider {
            width: parent.width
            bar: panel.widget.bar
            minimum: 12; maximum: 28; step: 1; integer: true
            activeFocusOnTab: true
            Keys.onLeftPressed: panel.widget.setOption("iconSize", value - 1)
            Keys.onRightPressed: panel.widget.setOption("iconSize", value + 1)
            opacity: activeFocus ? 1 : 0.85
            value: panel.widget.options.iconSize
            onReleased: function(value) { panel.widget.setOption("iconSize", value) }
          }
        }
        Column {
          visible: panel.page === "appearance"
          width: parent.width
          spacing: 8
          RowLayout {
            width: parent.width
            Text { text: "Icon spacing"; textFormat: Text.PlainText; color: Color.foreground; font.family: Style.font.family; font.pixelSize: 13; Layout.fillWidth: true }
            Text { text: panel.widget.options.iconGap + " px"; textFormat: Text.PlainText; color: Util.alpha(Color.foreground, 0.65); font.family: Style.font.family; font.pixelSize: 12 }
          }
          PanelSlider {
            width: parent.width
            bar: panel.widget.bar
            minimum: 2; maximum: 12; step: 1; integer: true
            activeFocusOnTab: true
            Keys.onLeftPressed: panel.widget.setOption("iconGap", value - 1)
            Keys.onRightPressed: panel.widget.setOption("iconGap", value + 1)
            opacity: activeFocus ? 1 : 0.85
            value: panel.widget.options.iconGap
            onReleased: function(value) { panel.widget.setOption("iconGap", value) }
          }
        }
        Toggle {
          width: parent.width
          visible: panel.page === "appearance"
          label: "Workspace numbers"
          titleSize: 13
          checked: panel.widget.options.showNumbers
          onClicked: panel.widget.setOption("showNumbers", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "appearance"
          label: "Group windows from the same app"
          titleSize: 13
          checked: panel.widget.options.groupApps
          onClicked: panel.widget.setOption("groupApps", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "appearance"
          label: "Show empty workspaces"
          description: "Keep workspaces 1–10 available when unused."
          titleSize: 13
          checked: panel.widget.options.showEmpty
          onClicked: panel.widget.setOption("showEmpty", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "windows"
          label: "Only this monitor"
          titleSize: 13
          checked: panel.widget.options.perMonitor
          onClicked: panel.widget.setOption("perMonitor", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "windows"
          label: "Show scratchpads"
          titleSize: 13
          checked: panel.widget.options.showScratchpad
          onClicked: panel.widget.setOption("showScratchpad", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "windows"
          enabled: panel.widget.options.showScratchpad
          opacity: enabled ? 1 : 0.45
          label: "Keep empty scratchpads visible"
          titleSize: 13
          checked: panel.widget.options.showEmptyScratchpad
          onClicked: panel.widget.setOption("showEmptyScratchpad", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "windows"
          label: "Include floating windows"
          titleSize: 13
          checked: panel.widget.options.showFloating
          onClicked: panel.widget.setOption("showFloating", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "windows"
          enabled: panel.widget.options.showFloating
          opacity: enabled ? 1 : 0.45
          label: "Mark floating windows"
          titleSize: 13
          checked: panel.widget.options.markFloating
          onClicked: panel.widget.setOption("markFloating", !checked)
        }
        Toggle {
          width: parent.width
          visible: panel.page === "appearance"
          label: "App icons"
          titleSize: 13
          checked: panel.widget.options.showIcons
          onClicked: panel.widget.setOption("showIcons", !checked)
        }
        Dropdown {
          visible: panel.page === "appearance"
          width: parent.width
          label: "Icons per workspace"
          value: String(panel.widget.options.maxIcons)
          options: [{value: "0", label: "All windows"}, {value: "3", label: "Up to 3"}, {value: "4", label: "Up to 4"}, {value: "6", label: "Up to 6"}, {value: "8", label: "Up to 8"}]
          onChanged: function(value) { panel.widget.setOption("maxIcons", Number(value)) }
        }
        Text {
          width: parent.width
          visible: panel.widget.saveError !== ""
          text: panel.widget.saveError
          textFormat: Text.PlainText
          wrapMode: Text.WordWrap
          color: Color.urgent
          font.family: Style.font.family
          font.pixelSize: 12
        }
        RowLayout {
          width: parent.width
          Button { text: "Reset defaults"; focusable: true; onClicked: panel.widget.resetOptions() }
          Item { Layout.fillWidth: true }
          Text { text: "Saved automatically"; textFormat: Text.PlainText; color: Util.alpha(Color.foreground, 0.55); font.family: Style.font.family; font.pixelSize: 11 }
        }
        Text {
          width: parent.width
          text: "Forked from Decent Workspaces by TheTrueFerret."
          textFormat: Text.PlainText
          wrapMode: Text.WordWrap
          color: Util.alpha(Color.foreground, 0.45)
          font.family: Style.font.family
          font.pixelSize: 10
        }
      }
    }
  }
}
