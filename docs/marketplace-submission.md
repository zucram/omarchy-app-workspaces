# Marketplace submission draft

Status: prepared locally. The public repository has not been created and no
marketplace issue has been sent. The planned repository is
`https://github.com/zucram/omarchy-app-workspaces`.

Review the preview, README, license, and validation limits before publication.
The owner must confirm the five checklist statements in the
[official submission guide](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/SUBMISSION.md).
After the repository is public and the statements are confirmed, check all
five boxes in the issue body below. Marketplace maintainers decide listing
approval; creating the issue does not publish the listing.

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

Initial preview tested on Omarchy 4.0.2 / Hyprland 0.56.2. Live multi-monitor
and vertical-bar coverage is pending; see docs/validation.md.

### Submission checklist

- [ ] The repository is public and contains installation and removal instructions.
- [ ] I have documented the plugin license and any external dependencies.
- [ ] I confirm that I own or have permission to submit this plugin and its preview assets.
- [ ] The plugin does not overwrite user configuration without explicit consent.
- [ ] I understand that approval is for listing and is not a security review.
