# Phase 1 — ClipEdit interaction prototype

> Throwaway prototype. This is evidence for a product decision, not production plugin code.

## Question

Does editing the selected clipboard entry inside Omarchy's clipboard overlay feel faster and more natural than leaving the overlay, and which detail-pane interaction should become the V1 behavior?

Three structurally different variants are available on one route through `?variant=`:

- **A — In-place pane:** preserves the 50/50 history/preview layout and replaces the preview with an editor. This matches the old native proof-of-concept.
- **B — Focus canvas:** collapses history to a context rail while editing, giving the draft most of the surface.
- **C — Before / after:** keeps the original visible above the draft so changes can be reviewed before saving.

## Run

```bash
python3 prototypes/phase-1/serve.py
```

Open <http://127.0.0.1:4173/?variant=A>. Use the floating arrows or the keyboard's left/right arrows to switch variants. Arrow switching is disabled while the editor is focused.

Append <code>&mode=editing</code> to open a variant directly in its editing state, for example <http://127.0.0.1:4173/?variant=C&mode=editing>.

Within each variant:

- `Ctrl+E` starts editing.
- `Ctrl+Enter` saves the draft as a new history entry.
- `Esc` cancels the draft.
- The interactions are in-memory stubs and never touch the real clipboard.

## Evaluation pass

For each variant, correct the selected entry from `The first compile chek passed.` to `The first compile check passed.` and assess:

1. Is the Edit action discoverable without knowing the shortcut?
2. Is it obvious that Save creates a new clipboard item and preserves the original?
3. Does focus land where expected?
4. Is enough history context retained during editing?
5. Would long or multiline text still be comfortable?
6. Does cancel feel safe and immediate?

Record the winning variant and rationale in `VERDICT.md` after hands-on evaluation. Phase 2 should carry only those validated decisions forward; this branch remains the primary source for discarded alternatives.

## Existing native proof

`old-native-proof.patch` captures the editing-only difference between Omarchy Quattro 4.0.0-alpha's built-in `omarchy.clipboard` and the old installed `sinkeat.clipboard` clone. It is retained as primary evidence that the native QML interaction is feasible. The clone is not the intended production architecture.
