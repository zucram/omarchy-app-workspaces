# Marketplace submission

The owner approved the public 0.1.0 preview release and this submission on
2026-09-08. The release includes the settings follow-up in `docs/validation.md`.

Repository: `https://github.com/zucram/omarchy-app-workspaces`.

The text below follows the
[official submission guide](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/SUBMISSION.md).
Marketplace automation posts validation and baseline results on the submission
issue. Marketplace maintainers decide listing approval; creating the issue
does not publish the listing.

Title: `[Plugin]: App Workspaces`

---

### Repository URL

https://github.com/zucram/omarchy-app-workspaces

### Category

Widgets

### Tags

bar, hyprland, workspaces

### Suggest a missing tag

_No response_

### Maintainer notes

MIT fork of Decent Workspaces by TheTrueFerret, starting at
`d92284395d7c04d3395f279df998dc19e84d9660`. Upstream attribution is retained in
LICENSE and documented in README and NOTICE. The original commit is preserved
as the fork's Git ancestor.

Adds installed app icons, spatial window ordering, separate scratchpad pills,
floating-window controls, and a native settings panel. No extra daemon or
runtime dependency beyond Omarchy 4 and its Hyprland/Quickshell shell. Uses
local desktop entries and compositor IPC; no network calls or privileged
operations. Settings update only this widget's inline bar entry. Installing it
does not automatically disable another widget or change Hyprland configuration.

The README includes optional Ko-fi support for this fork's maintenance.

Version 0.1.1 removes agent instruction files from the published source tree.
Release tests reject these files at any depth, and release archives use an
explicit runtime and documentation allowlist. Widget behavior is unchanged.

Initial preview tested on Omarchy 4.0.2 / Hyprland 0.56.2. Live multi-monitor
and vertical-bar coverage is pending; see docs/validation.md.

### Submission checklist

- [x] The repository is public and contains installation and removal instructions.
- [x] I have documented the plugin license and any external dependencies.
- [x] I confirm that I own or have permission to submit this plugin and its preview assets.
- [x] The plugin does not overwrite user configuration without explicit consent.
- [x] I understand that approval is for listing and is not a security review.
