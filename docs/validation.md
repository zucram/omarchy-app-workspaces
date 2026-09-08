# Initial release validation

Observed on 2026-09-08 with Omarchy 4.0.2, Hyprland 0.56.2, the Omarchy
Quickshell shell, a horizontal floating bar, and the scrolling layout.

## Passed

- Fourteen Node model tests: classless LibrePods, YouTube PWA URL matching,
  iconless launcher hints, late Beeper entries, exact overrides, spatial order,
  grouping, invalid settings, monitor filters, scratchpads, empty scratchpad
  destinations, floating-window filtering, and Lua literal escaping.
- Native `omarchy plugin validate` accepted the installed plugin.
- The marketplace's local manifest and preview validators passed. The chosen ID
  was absent from its current and retired listings. Its baseline analysis of
  local text files returned `passed`, with no findings or capabilities. This
  was a local preflight; the official GitHub snapshot review is still pending.
- `qmllint` exited zero with native Omarchy imports. It reported warnings for
  dynamic host properties and access to outer IDs; this is not a warning-free
  lint result.
- The live bar displayed real LibrePods, YouTube, Beeper, and T3 Code icons.
- Workspace three followed Obsidian, Teams, Helium, Outlook in screen order.
- Two controlled floating-window open/close cycles using the Beeper class
  resolved the Beeper icon each time and removed the empty test workspace.
  Floating-window filtering removed and restored the test icons.
- Activating a controlled scratchpad app revealed its special workspace and
  focused its exact address. The scratchpad visibility option removed the
  special pills and restored them when enabled again.
- Keyboard navigation opened both settings pages. A slider arrow key changed
  the saved icon size, and the floating-marker toggle saved through keyboard input. Escape dismissed the panel. Settings survived shell
  restarts during development.
- The final running shell log contained no App Workspaces QML warnings or errors.
- The workstation adapter passed isolated layout-preservation, repeated-install,
  rollback, and ambiguous-layout tests. Live rollback restored Decent Workspaces;
  redeployment selected App Workspaces in the same position.

## Limits

Actual Beeper process restart was not forced. Controlled windows exercised the
same class and compositor lifecycle, and the real Beeper window subsequently
resolved correctly. Tray-only apps have no workspace window to display.

Multiple monitors, vertical bars, mixed display scales, other themes, long
scratchpad names, and every browser's PWA class convention have not received
live coverage. Monitor filtering and spatial ordering have model coverage.
Scratchpad focus was exercised through the same activation function used by
app clicks; automated physical mouse clicking was not exercised.

Empty numbered workspaces depend on Hyprland's live workspace list. The empty
scratchpad preference remembers names during the current shell session and
always offers `special:scratchpad`. It does not create permanent workspace rules.

The native settings panel scrolls when a display cannot fit its full height.
Very short vertical bars and workspace strips with many windows may need an
icon limit. The plugin does not automatically hide occupied workspaces to fit.
