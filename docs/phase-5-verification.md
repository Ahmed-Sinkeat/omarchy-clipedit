# Phase 5 — compatibility verification

Run against the live session on 2026-09-08, Omarchy Quattro `4.0.0.alpha`,
with `sinkeat.clipedit` installed as a real third-party plugin and the
extension slot hosted by the enabled `sinkeat.clipboard` clone.

| Check | Result |
|---|---|
| Plugin discovered by `rescanPlugins` | `sinkeat.clipedit ['extension'] False` |
| `enablePlugin` records it in `shell.json` | `plugins[]` gains `{"id": "sinkeat.clipedit"}` |
| Extension loads, `host` injected | `manifests 1, hosted 1, items 1` |
| Edit action renders in the detail pane | `Edit  Ctrl+E`, bordered, bottom-right |
| `Ctrl+E` opens the editor | `handleKey → true, paneOpen=true` |
| Plain `E` still types into the search filter | `handleKey → false` |
| `Ctrl+F` is not claimed | `handleKey → false` |
| Focus lands in the editor | caret at end of text, typing goes to the pane |
| History stays visible and unchanged while editing | confirmed in capture |
| Multiline text | `line one / line two` preserved |
| Quotes and `$VAR` | `"quoted" 'single' $VAR` preserved verbatim |
| Arabic / Unicode | `آخر سطر عربي` renders and round-trips |
| Save copies the edit | `wl-paste` → `The first compile check passed.` |
| Save creates a new entry | history 300 → 301 |
| Original preserved below it | row 1 edited, row 2 original |
| Save closes the overlay | desktop pixel at the card centre after save |
| Cancel closes the pane, keeps the entry | `paneOpen=false`, clipboard unchanged |
| Cancel restores the preview and the action row | confirmed in capture |
| Image entries offer no Edit action | index 6 `type=image, actions=0` |
| Disable without restart | `manifests 0, items 0, actions 0` |
| Re-enable without restart | `manifests 1, items 1, actions 1` |
| Remove the plugin directory | registry drops it, clipboard behaves as before |
| Reinstall | back to `items 1, actions 1` |
| Shell restart | clean, no warnings from the slot or the extension |
| Omarchy shell test suite | `plugin-extensions` 19/19; `plugins`, `plugin-validate`, `clipboard`, `plugin-registry-contract` all pass |
| Repository-root plugin validation | passes with `manifest.json` and `ClipEdit.qml` at the Git root |
| Two consecutive saves | `clipedit-repro-first`, then `clipedit-repro-second`, both verified through `wl-paste` |
| Long source beyond the display cap | 9,019 characters opened in full; appending `-edited` saved 9,026 characters ending in `-tail-edited` |
| Empty edited result | `Ctrl+Enter` leaves the editor open; hint changes to `Enter text to copy`; Save is disabled |
| Physical `Ctrl+E` | exercised with `wtype`; editor opened with focus and the original text selected for editing |
| History click while editing | guarded in the host and covered by the clipboard regression suite |

## Not verified here

- **The built-in `omarchy.clipboard` as host.** `$OMARCHY_PATH` is
  `/usr/share/omarchy` in this session, which is root-owned; the identical host
  code was verified through the user-writable clone instead. The clone's
  `Clipboard.qml` is byte-identical to the upstream branch.
- **Installation from the published Git URL.** The repository root now passes `omarchy-plugin-validate`, but this checkout has no remote and cannot be tested through `omarchy plugin add` until it is published.

## One thing worth remembering

A `keepLoaded` panel plugin does **not** pick up its own QML changes from
plugin hot-reload — `rescanPlugins` reloads the source but the running instance
survives. `omarchy-restart-shell` is required after editing the host. Extension
plugins are picked up live.
