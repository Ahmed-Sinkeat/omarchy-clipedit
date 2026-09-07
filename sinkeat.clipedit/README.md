# ClipEdit

Edit clipboard text in place, inside Omarchy's own clipboard manager.

Select a text entry, press `Ctrl+E`, fix it, press `Ctrl+Enter`. The edited
text is copied; Omarchy's clipboard watcher files it as a new entry, so the
original stays one row below as a free undo.

```
┌──────────────────────────┬─────────────────────────────┐
│ Search clipboard…        │ Editing selected text       │
│                          │ The first compile check     │
│ ● The first compile chek │ passed.▌                    │
│   Previous item          │                             │
│                          │ Original kept  Cancel  Esc  │
│                          │        Copy new  Ctrl+Enter │
└──────────────────────────┴─────────────────────────────┘
```

| Action | Shortcut |
|---|---|
| Edit the selected entry | `Ctrl+E` |
| Copy the edit as a new entry | `Ctrl+Enter` |
| Cancel | `Esc` |

Text entries only. Images and empty entries offer no Edit action.

## Requires

The clipboard extension point, from Omarchy's
[`PluginExtensions`](https://github.com/basecamp/omarchy) slot. Until that
lands upstream, ClipEdit needs a clipboard plugin that offers the slot — see
[docs/phase-2-extension-hook.md](../docs/phase-2-extension-hook.md).

## Install

```bash
omarchy plugin add https://github.com/Ahmed-Sinkeat/omarchy-clipedit.git
omarchy plugin enable sinkeat.clipedit
```

By hand:

```bash
cp -r sinkeat.clipedit ~/.config/omarchy/plugins/
omarchy-shell shell rescanPlugins
omarchy-shell shell enablePlugin sinkeat.clipedit '{}'
```

Removing it restores the clipboard exactly as it was; nothing here touches
`clipboard-history.json`.

## What it does not do

No image editing, no rich text, no AI rewriting, no second clipboard history,
and no replacing an existing history entry. Other transformations belong in
other extensions — the slot ClipEdit uses is not ClipEdit's.
