# Phase 1 — chosen ClipEdit interaction

> Throwaway prototype. This is evidence for a product decision, not production plugin code.

## Direction

Variant A is the sole current direction:

- retain Omarchy's native 50/50 clipboard history and detail layout,
- show a visible Edit action in the detail pane,
- replace the preview with an editor in place,
- keep history visible while editing,
- preserve the original history entry,
- and close the overlay after copying the edited text.

Earlier alternatives remain available in Git history at commit `e5b1a6e`.

## Run

```bash
python3 prototypes/phase-1/serve.py
```

Open <http://127.0.0.1:4173/>. To open directly in the editing state, use <http://127.0.0.1:4173/?mode=editing>.

Keyboard controls:

- `Ctrl+E` starts editing.
- `Ctrl+Enter` saves the draft as a new history entry.
- `Esc` cancels the draft.
- The interactions are in-memory stubs and never touch the real clipboard.

## Evaluation pass

Correct the selected entry from `The first compile chek passed.` to `The first compile check passed.` and confirm:

1. Edit is discoverable without knowing the shortcut.
2. Focus lands in the editor.
3. The visible history provides enough context.
4. Long and multiline text remain comfortable.
5. Cancel feels safe and immediate.
6. Closing after Save feels natural.

## Existing native proof

`old-native-proof.patch` captures the editing-only difference between Omarchy Quattro 4.0.0-alpha's built-in `omarchy.clipboard` and the old installed `sinkeat.clipboard` clone. It proves the native QML interaction is feasible but is not the intended production architecture.
