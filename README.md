# ClipEdit for Omarchy

Edit clipboard text in place, inside Omarchy's own clipboard manager, as a
genuine third-party plugin.

The design proposal is [omarchy-clipedit-project.md](omarchy-clipedit-project.md).

## State

| Phase | Status |
|---|---|
| 1 — validate the interaction | Done. Variant A chosen, see [prototypes/phase-1/VERDICT.md](prototypes/phase-1/VERDICT.md) |
| 2 — design the extension hook | Done, see [docs/phase-2-extension-hook.md](docs/phase-2-extension-hook.md) |
| 3 — implement it upstream | Done, on the `clipboard-extension-point` branch of the Omarchy fork |
| 4 — build `sinkeat.clipedit` | Done, see [sinkeat.clipedit/](sinkeat.clipedit/) |
| 5 — compatibility testing | Done, see [docs/phase-5-verification.md](docs/phase-5-verification.md) |

Installed and working in this session. `Ctrl+E` on a text entry, `Ctrl+Enter`
to save, `Esc` to cancel.

## Layout

```
sinkeat.clipedit/     the plugin: manifest, ClipEdit.qml, README
docs/                 phase records
prototypes/phase-1/   throwaway UX prototype, kept as evidence
```

## The upstream half

The plugin needs one thing Omarchy does not ship yet: a slot a plugin can
offer to other plugins. That change lives in the Omarchy fork at
`~/Projects/omarchy/omarchy`, branch `clipboard-extension-point`:

```
shell/Ui/PluginExtensions.qml     the slot
shell/Ui/PluginExtensions.js      shortcut grammar + host lookup
shell/plugins/clipboard/          the first host
test/shell.d/plugin-extensions-test.sh
```

It contains no editing logic. Push it and open the PR against
`basecamp/omarchy` when you are ready.

## Live test bed

`$OMARCHY_PATH` is `/usr/share/omarchy` (root-owned), so the host half cannot
be installed there without `omarchy dev link` and a reboot. Instead the
enabled `sinkeat.clipboard` clone in `~/.config/omarchy/plugins/` carries a
byte-identical copy of the upstream `Clipboard.qml` plus `PluginExtensions.*`.

**This is temporary.** Once the upstream change ships, delete the clone and
re-enable `omarchy.clipboard`:

```bash
omarchy plugin remove sinkeat.clipboard
omarchy-shell shell setPluginEnabled omarchy.clipboard true
```

ClipEdit itself needs no change when that happens — it names
`omarchy.clipboard` as its host either way.

## Re-verifying

```bash
cd ~/Projects/omarchy/omarchy && ./test/shell.d/plugin-extensions-test.sh
omarchy-shell shell listPlugins | jq '.[] | select(.id == "sinkeat.clipedit")'
```

After editing the host (`Clipboard.qml` or `PluginExtensions.qml`), copy it
into the clone and run `omarchy-restart-shell` — a `keepLoaded` plugin does not
pick up its own changes from plugin hot-reload. Editing `ClipEdit.qml` alone
reloads live.
