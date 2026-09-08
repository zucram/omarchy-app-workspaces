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
  was a local preflight. The marketplace submission issue records the official
  GitHub snapshot review separately.
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
The initial scratchpad focus check used the activation function directly.
The follow-up below adds compositor pointer coverage.

With Show empty workspaces enabled, unused destinations 1–10 remain available.
Other empty numbered workspaces depend on Hyprland's live workspace list.
The empty scratchpad preference remembers names during the current shell session and
always offers `special:scratchpad`. It does not create permanent workspace rules.

The native settings panel scrolls when a display cannot fit its full height.
Very short vertical bars and workspace strips with many windows may need an
icon limit. The plugin does not automatically hide occupied workspaces to fit.

## Settings follow-up, 2026-09-08

Reproduced a missed right-click when another native panel was open. With the
calendar open, right-clicking an app only dismissed the calendar. With panels
closed, the same click opened App Workspaces settings. The plugin's MouseAreas
were absent from the bar's registered click targets, which KeyboardPanel uses
to forward clicks from its overlay.

Workspace pills and app icons now use native WidgetButtons. Registration puts
app buttons after their enclosing pill so forwarded clicks select the app.
The `status` response includes `settingsOpen` for verification.

Show empty workspaces moved to Appearance. Previously it only included empty
workspaces still present in Hyprland's live list, so toggling it could leave
the bar unchanged. It now offers unused destinations 1–10, matching Omarchy's
standard number shortcuts. It preserves live IDs above 10 and excludes known
workspaces on other monitors when Only this monitor is enabled. These are bar
destinations, with no persistent workspace rules installed.

Live checks used a temporary Wayland virtual pointer on the existing horizontal
floating bar. No mouse-button binding or input configuration was installed.

- Right-click opened settings on a workspace label and an app icon with panels
  closed, and from the open calendar. The scratchpad also opened settings from
  the calendar.
- Left-click on an app from the calendar focused its exact window address.
- Settings stayed open after an explicit model refresh and the periodic refresh.
- Clicking Done closed settings.
- Clicking Show empty workspaces in Appearance displayed destinations 1–10.
  Clicking empty destination 4 activated workspace 4. Returning to the original
  workspace and disabling the option restored the occupied numbers 1, 2, and 3.
- Mouse navigation reached Windows, where Show empty workspaces was absent.
  Both settings screenshots were refreshed with panel-only captures.
- The installer preserved saved options. After the checks, Show empty workspaces
  was restored to off. A cropped bar capture confirmed the existing appearance.
  The running log had no plugin QML warnings or errors.
- Native plugin validation passed. `qmllint` on both QML files with resolved
  native imports exited zero, with warnings for dynamic properties and outer IDs.
- All 16 Node model tests passed. The regression for missing unused destinations
  failed against the previous model before the fix.

The installer was unchanged, so its earlier tests were not repeated. The other
live coverage limits above still apply.

## Packaging correction, 0.1.1, 2026-09-08

The marketplace reviewer identified root agent instruction files in 0.1.0.
Version 0.1.1 removes them from the published source tree. The release packager
uses an explicit list of 12 runtime, attribution, preview, and documentation
files. The workstation installer uses that same packager.

- The release regression failed against the previous tree, identifying AGENTS.md.
- All 19 Node tests passed, including nested instruction-path rejection and
  inspection of the archive's exact file list and extracted contents.
- Both isolated workstation installer tests passed.
- Live deployment contained exactly the 12 allowed files, with no agent
  instruction files, development scripts, tests, or nested release archives.
- Native plugin validation and shell readiness passed. IPC reported 0.1.1,
  the saved options were retained, and the native settings panel opened.
- The live shell log contained no plugin QML warnings or errors.

The only runtime-source change is the reported version. The earlier UI and
model evidence still applies; hardware and browser coverage was not expanded.
