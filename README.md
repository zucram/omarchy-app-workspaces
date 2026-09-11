# App Workspaces

Real app icons for the Omarchy bar, ordered like your windows, with separate
scratchpad pills and configurable floating-window markers.

**An MIT fork of [Decent Workspaces by TheTrueFerret](https://github.com/TheTrueFerret/omarchy-decent-workspaces).**
See [NOTICE.md](NOTICE.md) for the starting commit and changes.

![App Workspaces showing numbered workspaces and a scratchpad](preview.png)

## Use

- Click a workspace number to switch to it. Scroll over the widget to cycle workspaces.
- Click an app to focus its window. Scratchpad apps reveal their workspace first.
- Click a scratchpad label to show or hide it. `S` means the default scratchpad;
  other named scratchpads use their names.
- Hover an app for its name and window title. A small outlined corner marker
  identifies a floating window.
- Right-click any workspace or app for settings. Changes save immediately.

The default is one icon per window, ordered left to right and then top to
bottom. Empty numbered workspaces are hidden unless active. Scratchpads stay
reachable even when their last monitor differs from the bar's monitor.
Floating and pinned windows appear in their reported workspace; pinned windows
are not duplicated across workspace pills.

## Requirements

Omarchy 4 (Quattro), its Quickshell shell, and Hyprland with the Lua dispatcher
API. Tested with Omarchy 4.0.2 and Hyprland 0.56.2. Older Waybar-based Omarchy
versions are unsupported. The plugin uses installed desktop entries and icon
themes. It needs no daemon, downloaded icon pack, or additional runtime package.
Node.js is only needed for development tests.

## Install

```bash
omarchy plugin add https://github.com/zucram/omarchy-app-workspaces.git --enable
omarchy bar put io.github.zucram.app-workspaces --section left --index 1
```

Choose which existing workspace widget to disable in Bar Studio. If replacing
Decent Workspaces, disable it after checking the new widget:

```bash
omarchy plugin disable io.github.thetrueferret.decent-workspaces
```

For a local checkout, build and extract the runtime archive, then enable it:

```bash
node scripts/package-release.cjs
mkdir -p ~/.config/omarchy/plugins/io.github.zucram.app-workspaces
tar -xzf app-workspaces-0.1.1.tar.gz -C ~/.config/omarchy/plugins/io.github.zucram.app-workspaces
omarchy plugin validate ~/.config/omarchy/plugins/io.github.zucram.app-workspaces
omarchy restart shell
omarchy plugin enable io.github.zucram.app-workspaces --section left --index 1
```

Restart the shell after updating QML files. A plugin rescan alone can retain
cached components. Settings changes apply without a restart.

The plugin does not install Hyprland bindings, change window rules, or replace
another widget automatically. Placement and replacement use Omarchy controls.

## Settings

Right-click the widget to open **Appearance** and **Windows**. Use Tab to move
between controls, Left/Right on sliders, and Space or Enter on buttons and
toggles. Escape closes the panel. Reset defaults resets both pages.

[Appearance panel](docs/appearance.png) · [Window controls](docs/windows.png)

| Setting | Default | Behavior |
| --- | --- | --- |
| App icons | On | Turn off for labels only. |
| Workspace numbers | On | Keep numbers beside the app icons. Empty pills always retain a label. |
| Icon size | 20 px | 12–28 px. |
| Icon spacing | 6 px | 2–12 px. |
| Icons per workspace | All | Limit the visible count and show `+N` for the rest. |
| Group windows from the same app | Off | Show the leftmost window for each class; clicking focuses that representative. |
| Show empty workspaces | Off | In Appearance. Include unused destinations 1–10 and other empty workspaces reported by Hyprland. |
| Only this monitor | On | Filter numbered workspaces to the bar's monitor. |
| Show scratchpads | On | Separate pills for special workspaces. |
| Keep empty scratchpads visible | Off | Retain the default scratchpad and named scratchpads encountered during this shell session. |
| Include floating windows | On | Include floating windows in numbered and scratchpad pills. |
| Mark floating windows | On | Draw a small corner outline on floating-window icons. |

Settings live on the widget entry in `~/.config/omarchy/shell.json`.
The equivalent keys are `showIcons`, `showNumbers`, `iconSize`, `iconGap`,
`maxIcons` (`0` means all), `groupApps`, `showEmpty`, `perMonitor`,
`showScratchpad`, `showEmptyScratchpad`, `showFloating`, and `markFloating`.
For example:

```bash
omarchy bar set io.github.zucram.app-workspaces iconSize 22 --json
```

### Missing or unexpected icons

The resolver checks desktop IDs, startup classes, web-app URLs, launcher names,
and the shell's lookup hints. Classless apps can match an exact launcher name
through their window title. Unknown apps show an initial tile. A fallback tile
can also mean the selected icon file is missing from the installed icon theme.

For an unusual app, add an exact class-to-desktop-ID mapping:

```bash
omarchy bar set io.github.zucram.app-workspaces iconOverrides '{"Beeper":"beeper","title:LibrePods":"me.kavishdevar.librepods"}' --json
```

Keys are case-sensitive. `title:` keys match exact titles. Values name installed
desktop entries, with an optional `.desktop` suffix. They are not commands or
arbitrary paths. Overrides use the CLI; the settings panel covers presentation.
Reset defaults preserves these mappings.

### Diagnostics

```bash
omarchy-shell io.github.zucram.app-workspaces status
omarchy-shell io.github.zucram.app-workspaces refresh
omarchy-shell io.github.zucram.app-workspaces open
```

`status` reports local window titles, icon sources, ordering, settings, and
whether the settings panel is open (`settingsOpen`).
Review titles before sharing its output. Nothing is transmitted by the plugin.
Window events trigger a refresh. A one-second `hyprctl -j clients` query also
catches missed close events and geometry changes. Each successful response
replaces the window list, removing closed windows even if the shell cache still
contains them. Failed queries preserve the last valid list. Queries never
overlap, and a query is stopped after two seconds. Unchanged snapshots keep
their delegates.

## Remove

```bash
omarchy plugin remove io.github.zucram.app-workspaces
```

Re-enable your previous widget in Bar Studio, or for Decent Workspaces:

```bash
omarchy plugin enable io.github.thetrueferret.decent-workspaces --section left --index 1
```

## Develop

```bash
node --test tests/*.cjs
omarchy plugin validate .
```

Model tests exercise matching, lifecycle misses, ordering, filters, malformed
settings, and Lua-string escaping. QML behavior also needs a running desktop;
see [validation evidence and limits](docs/validation.md). The initial release
is a preview, not a claim of broad hardware coverage.

Release checks reject agent instruction files at any depth in the source tree.
`node scripts/package-release.cjs` builds an archive containing only the runtime,
attribution, preview, and user documentation listed in that script. Tests inspect
the extracted archive and compare every file with its source. CI runs both model
and release checks. Keep development instructions outside the published plugin.

## Support

[Support on Ko-fi](https://ko-fi.com/K3K11RWTSL) to help maintain App Workspaces.

## License

MIT. Copyright TheTrueFerret and zucram. Application icons belong to their
respective owners and are loaded from the user's system.
