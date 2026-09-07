# ClipEdit for Omarchy
## A Native Clipboard Editing Plugin with an Upstream Extension API

**Status:** Design proposal  
**Target:** Omarchy Quattro  
**Plugin ID:** `sinkeat.clipedit`

---

## 1. Project Summary

ClipEdit is a lightweight Omarchy plugin that lets users edit clipboard text directly inside Omarchy’s existing clipboard manager.

The goal is intentionally small:

> Select a clipboard entry, press **Edit**, modify the text in the existing preview pane, save it, and continue working.

ClipEdit should not replace Omarchy’s clipboard manager, open a second clipboard application, or maintain its own clipboard history.

The core design requirement is:

> **ClipEdit must be a real third-party plugin while still appearing inside the native Omarchy clipboard UI.**

Achieving that cleanly requires a small, generic extension point in Omarchy’s clipboard plugin. The extension mechanism belongs upstream; the editing feature remains in `sinkeat.clipedit`.

---

## 2. Problem

Omarchy’s clipboard manager already handles the common clipboard workflow well:

- browse history,
- search,
- preview an entry,
- copy,
- paste,
- delete,
- and open content externally.

What it does not support is editing clipboard text.

Today, if a user copies:

```text
The first compile chek passed.
```

and notices a typo, the workflow is usually:

```text
Clipboard
   ↓
Paste somewhere
   ↓
Edit
   ↓
Select again
   ↓
Copy again
```

ClipEdit reduces this to:

```text
Clipboard
   ↓
Edit
   ↓
Save
```

This is especially useful for:

- fixing typos,
- removing unwanted lines,
- changing generated text before pasting,
- cleaning shell commands,
- editing URLs or paths,
- adjusting AI-generated text,
- and making small formatting changes without opening another application.

---

## 3. Product Principle

ClipEdit is **not another clipboard manager**.

It should feel like a missing native action inside the clipboard manager that Omarchy already provides.

The user should not need to think:

> “I am opening ClipEdit now.”

The intended experience is:

> “I am editing this clipboard entry.”

That distinction drives the architecture.

---

## 4. Desired User Experience

The normal clipboard manager remains unchanged:

```text
┌──────────────────────────┬─────────────────────────────┐
│ Search clipboard...      │                             │
│                          │ Selected clipboard text     │
│ ● Item 1                 │ appears here as usual.      │
│   Item 2                 │                             │
│   Item 3                 │                             │
│                          │                      Edit   │
└──────────────────────────┴─────────────────────────────┘
```

When the selected entry is text, ClipEdit contributes an **Edit** action.

Suggested shortcut:

```text
Ctrl + E
```

After activation, the existing preview pane becomes editable:

```text
┌──────────────────────────┬─────────────────────────────┐
│ Clipboard history        │                             │
│                          │ The first compile check     │
│ ● Item 1                 │ passed successfully.▌       │
│   Item 2                 │                             │
│   Item 3                 │                             │
│                          │ Esc Cancel   Ctrl+Enter Save│
└──────────────────────────┴─────────────────────────────┘
```

No new window appears.

No second overlay appears.

No replacement clipboard manager is installed.

---

## 5. Save Behavior

For the first version, saving should **not mutate the original history entry**.

Instead:

1. the edited text is written to the system clipboard,
2. Omarchy’s existing clipboard watcher detects it,
3. the edited version appears as a new history entry,
4. the original remains below it.

Example:

```text
Before editing:

1. Hello wolrd
2. Previous item
3. Previous item
```

After editing and saving:

```text
1. Hello world     ← edited result / current clipboard
2. Hello wolrd     ← original preserved
3. Previous item
4. Previous item
```

This behavior is simple, safe, and naturally provides a form of undo.

Replacing an existing history entry in place is explicitly **out of scope for V1**.

---

## 6. Why We Should Not Fork `omarchy.clipboard`

A working prototype can be made by cloning the built-in clipboard plugin and modifying `Clipboard.qml`.

That proves the interaction is possible, but it is not the desired architecture.

A permanent fork would mean:

- duplicating hundreds of lines of Omarchy code,
- replacing the user’s normal clipboard plugin,
- manually tracking upstream clipboard changes,
- carrying merge work across Omarchy releases,
- and turning a small feature into maintenance of an entire clipboard manager.

ClipEdit should own only the code required for editing.

Omarchy should continue to own the clipboard manager.

---

## 7. Why a Standalone Overlay Is Also Not Enough

A completely separate plugin would be technically clean:

```text
Super + Shift + V
        ↓
ClipEdit overlay
        ↓
Edit current clipboard
```

However, this loses the most important part of the experience.

The user already has the exact clipboard item selected inside Omarchy’s clipboard manager. Opening another overlay introduces unnecessary context switching and makes ClipEdit feel like a separate application.

Therefore:

> **The plugin must remain independent, but its action and editing UI must be available inside the native clipboard overlay.**

---

## 8. Proposed Architecture

The project has two parts.

### 8.1 Upstream: Clipboard Extension API

Omarchy gains a small, generic mechanism that allows enabled plugins to contribute actions to the clipboard manager.

Conceptually:

```text
Omarchy
  │
  ├── Plugin Registry
  │
  └── omarchy.clipboard
          │
          └── Clipboard Extension Slot
                    │
          ┌─────────┼─────────┐
          │         │         │
       ClipEdit   Future    Future
                  Plugin    Plugin
```

The upstream change should **not contain clipboard editing logic**.

It should only provide a reusable extension mechanism.

Possible future extensions could include:

- Translate
- Format JSON
- Save to file
- Send to…
- Transform case
- Open in another tool

ClipEdit simply becomes the first plugin that uses the API.

---

### 8.2 Third-Party: `sinkeat.clipedit`

ClipEdit registers a clipboard action approximately equivalent to:

```text
id:       sinkeat.clipedit.edit
label:    Edit
shortcut: Ctrl+E
supports: text
```

The exact API shape should follow Omarchy’s existing QML/plugin conventions rather than introducing a large new framework.

The important contract is:

```text
Clipboard item
    ↓
Extension receives selected entry
    ↓
Extension requests editing mode
    ↓
Native detail pane hosts editable content
    ↓
Extension returns edited text
    ↓
Text is copied through wl-copy
```

---

## 9. Extension API Design Goals

The upstream API should be:

### Small

No general-purpose plugin framework redesign.

### Generic

It must not be named or structured specifically around ClipEdit.

### Optional

If no clipboard extension plugins are installed, the native clipboard UI should behave exactly as it does today.

### Safe

A broken third-party extension should not break clipboard history.

### Discoverable

The clipboard UI should be able to show contributed actions and shortcuts naturally.

### Context-aware

An extension should be able to declare what it supports.

For example:

```text
text
image
url
file
any
```

ClipEdit V1 supports only:

```text
text
```

---

## 10. Minimal Conceptual API

The final implementation may differ, but the smallest useful contract is roughly:

```qml
ClipboardExtension {
    id: "sinkeat.clipedit.edit"
    label: "Edit"
    shortcut: "Ctrl+E"

    supports: function(entry) {
        return entry.type === "text"
    }

    activate: function(entry, host) {
        host.openEditor(entry.text)
    }
}
```

The clipboard manager should not know what “editing” means internally.

A slightly more generic host API could expose a detail-pane mode:

```qml
host.openPane({
    component: editorComponent,
    data: entry
})
```

That would make the extension point useful beyond ClipEdit.

The preferred implementation should be chosen after inspecting the current `PluginRegistry.qml`, `Clipboard.qml`, and shell IPC patterns.

---

## 11. Current Omarchy Capabilities We Can Reuse

The existing system already provides most of the required infrastructure.

Relevant existing behavior includes:

- clipboard history stored in Omarchy state,
- clipboard capture through the current watcher,
- plugin discovery and loading,
- plugin-to-plugin calls through shell IPC,
- support for user-installed plugins,
- the native clipboard overlay,
- and a persistent built-in clipboard plugin.

This means ClipEdit does **not** need to build:

- a new history database,
- a clipboard daemon,
- a second clipboard watcher,
- a custom plugin loader,
- or a new shell.

The only missing architectural piece is a clean way for one plugin to contribute behavior inside another plugin’s UI.

---

## 12. Clipboard Write Path

Edited text should be written through standard input to `wl-copy`.

Conceptually:

```text
edited text
    ↓
stdin
    ↓
wl-copy
    ↓
Wayland clipboard
    ↓
Omarchy clipboard watcher
    ↓
new history entry
```

Passing clipboard content through process arguments should be avoided because clipboard entries can be large and shell argument limits can be exceeded.

---

## 13. MVP Scope

### Included

- text entries only,
- Edit action inside native Omarchy clipboard,
- keyboard shortcut,
- editing in the existing right-side/detail pane,
- multiline text,
- scrolling for long text,
- Unicode,
- `Esc` to cancel,
- `Ctrl+Enter` to save,
- save to system clipboard,
- new history entry created through normal Omarchy capture behavior.

### Not Included

- image editing,
- rich text,
- markdown preview,
- AI rewriting,
- grammar correction,
- translation,
- history-entry replacement,
- multiple editor tabs,
- custom themes,
- a second clipboard history,
- a second clipboard overlay,
- or a fork of the built-in clipboard plugin.

The project should remain intentionally small.

---

## 14. Keyboard Proposal

Initial proposal:

| Action | Shortcut |
|---|---|
| Enter edit mode | `Ctrl+E` |
| Save | `Ctrl+Enter` |
| Cancel | `Esc` |

Before finalizing these bindings, they should be checked against existing clipboard shortcuts and Omarchy conventions.

---

## 15. Prototype Strategy

A temporary clone of `omarchy.clipboard` is useful as a **prototype only**.

Its purpose is to answer UX questions quickly:

- Does editing in the right pane feel natural?
- Is `Ctrl+E` discoverable enough?
- Should the list remain navigable while editing?
- Should focus move directly into the editor?
- How should very long text behave?
- What should happen after save?

Once the interaction is validated, the clone should be discarded as the final architecture.

The production design should be:

```text
small upstream extension hook
        +
independent sinkeat.clipedit plugin
```

---

## 16. Implementation Plan

### Phase 1 — Validate the Interaction

Use the existing prototype to test the editing experience manually.

Success condition:

> Editing a selected clipboard item in the preview pane feels faster and more natural than pasting into another application.

---

### Phase 2 — Design the Smallest Extension Hook

Inspect:

```text
Clipboard.qml
PluginRegistry.qml
shell.qml
plugin manifest contract
```

Determine the minimum mechanism needed for a plugin to:

1. announce a clipboard action,
2. receive the selected entry,
3. render or request a detail-pane mode,
4. return a result.

Avoid designing capabilities that no current use case requires.

---

### Phase 3 — Implement the Upstream API

Create a focused Omarchy change.

The PR should be framed around extensibility, for example:

> Allow plugins to contribute contextual actions to the clipboard overlay.

It should not contain ClipEdit-specific business logic.

---

### Phase 4 — Build `sinkeat.clipedit`

Move editing behavior into the standalone plugin.

The plugin should contain only:

- its manifest,
- clipboard extension registration,
- editor UI,
- save/cancel logic,
- and clipboard write handling.

---

### Phase 5 — Test Compatibility

Verify:

- plugin install,
- plugin removal,
- Omarchy with ClipEdit disabled,
- long text,
- multiline text,
- Arabic and other Unicode text,
- quotes,
- URLs,
- shell commands,
- empty content,
- rapid save/cancel,
- clipboard history updates,
- shell reload,
- and keyboard focus.

---

## 17. Success Criteria

The project is successful when all of the following are true:

1. `sinkeat.clipedit` can be installed as a normal third-party Omarchy plugin.
2. The built-in clipboard plugin is not copied or replaced.
3. `Super + Ctrl + V` still opens the normal Omarchy clipboard manager.
4. Selecting a text item exposes an Edit action.
5. Editing happens inside the native clipboard interface.
6. Saving places the edited text on the system clipboard.
7. Omarchy records the result through its normal clipboard history path.
8. Removing ClipEdit restores the exact normal clipboard experience.
9. Omarchy updates do not require manually merging a forked `Clipboard.qml`.
10. The upstream change is generic enough to support other clipboard extensions later.

---

## 18. Main Technical Risk

The largest risk is not clipboard editing itself.

That part is already straightforward.

The main risk is designing an extension point that is:

- small enough for Omarchy maintainers to accept,
- generic enough not to be a ClipEdit-only hack,
- but not so abstract that it becomes an unnecessary framework.

Therefore the project should resist overengineering.

The goal is **one missing hook**, not a new plugin architecture.

---

## 19. Future Possibilities

These are intentionally outside V1, but the extension API could later make them possible without modifying the clipboard manager again:

```text
Edit
Translate
Fix grammar
Format JSON
Trim whitespace
Change case
Save to file
Open in editor
Send to application
Custom text transformations
```

ClipEdit itself should remain focused on editing.

Other transformations can live in separate plugins.

---

## 20. Final Architecture

```text
                         Omarchy
                            │
                   Plugin infrastructure
                            │
                  omarchy.clipboard
                            │
                 Clipboard extension API
                            │
          ┌─────────────────┴─────────────────┐
          │                                   │
sinkeat.clipedit                        Future plugins
          │
          ├── contributes "Edit"
          ├── receives selected text
          ├── uses native detail pane
          └── saves through wl-copy
                            │
                            ↓
                    System clipboard
                            │
                            ↓
              Existing Omarchy watcher
                            │
                            ↓
                   Clipboard history
```

---

## 21. Project Position

ClipEdit should be judged as a **small native workflow improvement**, not as a new clipboard application.

Its value comes from being:

- instant,
- integrated,
- lightweight,
- removable,
- and architecturally clean.

The final product should feel as though Omarchy always supported clipboard editing, while the implementation remains a genuine third-party plugin.
