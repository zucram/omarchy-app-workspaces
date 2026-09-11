# Changelog

## Unreleased

- Remove stale app icons after missed window-close events by reading complete
  Hyprland client snapshots instead of the shell's cached toplevel list.


## 0.1.1 — package correction

- Remove agent instruction files from the published source and runtime package.
- Build release archives from an explicit runtime and documentation allowlist.
- Reject agent instruction files at any depth in release tests.
- Preserve the 0.1.0 widget behavior and settings.

## 0.1.0 — initial preview

- Fork Decent Workspaces 1.0.0, preserving its MIT attribution.
- Replace font glyphs with installed application icons and readable fallbacks.
- Order icons by window position and refresh on window and geometry changes.
- Add separate scratchpad pills and floating-window filters and markers.
- Add native Appearance and Windows settings, with keyboard controls.
- Preserve one icon per window by default; make grouping and overflow optional.
- Open settings on right-click, including while another native panel is open.
- Offer unused destinations 1–10 through Show empty workspaces in Appearance.
