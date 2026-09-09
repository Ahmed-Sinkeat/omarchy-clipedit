# ClipEdit for Omarchy

Edit clipboard text inside Omarchy's native clipboard manager. Select a text entry, press `Ctrl+E`, edit it in the existing detail pane, then press `Ctrl+Enter` to copy the edit as a new clipboard entry. `Esc` cancels and preserves the original.

> [!IMPORTANT]
> ClipEdit is currently a preview. It requires the extension support proposed in [Omarchy PR #10919](https://github.com/omacom/omarchy/pull/10919), which is not part of a released Omarchy version yet.

ClipEdit implements [Variant A](prototypes/phase-1/VERDICT.md). It does not add a second overlay, replace clipboard history, or edit images.

## Project state

| Phase | Status |
|---|---|
| 1 — validate the interaction | Done — Variant A selected |
| 2 — design the extension hook | Done — see [the extension design](docs/phase-2-extension-hook.md) |
| 3 — implement it upstream | Submitted in [Omarchy PR #10919](https://github.com/omacom/omarchy/pull/10919) |
| 4 — build ClipEdit | Done — plugin manifest and entry point now live at the repository root |
| 5 — compatibility testing | In progress — public package validation passes; final built-in-host verification remains |

The full proposal is in [omarchy-clipedit-project.md](omarchy-clipedit-project.md).

## Shortcuts

| Action | Shortcut |
|---|---|
| Edit the selected text entry | `Ctrl+E` |
| Copy the edit as a new entry | `Ctrl+Enter` |
| Cancel | `Esc` |

An empty edit is not saved: the editor stays open and asks for text. Images and empty history entries do not offer the Edit action.

## Requirements

ClipEdit uses Omarchy's proposed `PluginExtensions` slot. Until [Omarchy PR #10919](https://github.com/omacom/omarchy/pull/10919) lands, it needs the matching host implementation from the fork's [`clipboard-extension-point`](https://github.com/Ahmed-Sinkeat/omarchy/tree/clipboard-extension-point) branch. The temporary `sinkeat.clipboard` clone in the development session provides that host.

## Install

The public repository can be installed normally because `manifest.json` is at the repository root:

```bash
omarchy plugin add https://github.com/Ahmed-Sinkeat/omarchy-clipedit.git
omarchy plugin enable sinkeat.clipedit
```

The extension point must also be present in the running Omarchy version; installing ClipEdit on a standard release does not make it usable yet.

## Layout

```text
manifest.json          third-party plugin manifest
ClipEdit.qml           editor UI and host interaction
ClipEditModel.js       reusable clipboard-write lifecycle
test/                  plugin regression tests
docs/                  extension design and verification records
prototypes/phase-1/    retained interaction evidence
```

## Verification

```bash
./test/clipedit-test.sh
cd ~/Projects/omarchy/omarchy
./bin/omarchy-plugin-validate ~/Projects/omarchy/plugins
./test/shell.d/clipboard-test.sh
./test/shell.d/plugin-extensions-test.sh
```

See [the compatibility record](docs/phase-5-verification.md) for the live-session coverage and remaining release checks.

## License

ClipEdit is available under the [MIT License](LICENSE).

## The upstream half

The upstream change is [Omarchy PR #10919](https://github.com/omacom/omarchy/pull/10919). It contains no ClipEdit-specific editing logic. After it ships, remove the temporary clipboard clone and re-enable `omarchy.clipboard`:

```bash
omarchy plugin remove sinkeat.clipboard
omarchy-shell shell setPluginEnabled omarchy.clipboard true
```
