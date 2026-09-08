import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "ClipEditModel.js" as ClipEditModel

// An Edit action for the Omarchy clipboard.
//
// Saving copies the edited text instead of rewriting the entry: the
// clipboard's own watcher then files it as a new entry, so the original stays
// one row below as a free undo and nothing here has to touch history.json.
Item {
  id: root

  // Injected by the clipboard's PluginExtensions slot.
  property var host: null
  property var manifest: null

  readonly property string label: "Edit"
  readonly property string shortcut: "Ctrl+E"

  function supports(entry) {
    return !!entry && entry.type === "text" && String(entry.text || "").length > 0
  }

  function activate(entry) {
    if (!root.host || !root.supports(entry)) return
    root.host.openPane(editorPane, entry)
  }

  function cancel() {
    if (root.host) root.host.closePane()
  }

  function save(text) {
    if (!ClipEditModel.startCopy(copyProcess, text)) return false
    if (root.host) root.host.requestClose()
    return true
  }

  // The text goes over stdin, never argv: a clipboard entry can exceed
  // MAX_ARG_STRLEN, and exec would fail with E2BIG and lose the edit silently.
  Process {
    id: copyProcess

    property string payload: ""

    command: ["wl-copy"]
    onStarted: ClipEditModel.writePendingCopy(copyProcess)
  }

  Component {
    id: editorPane

    Item {
      id: pane

      readonly property string original: root.host && root.host.paneEntry
        ? String(root.host.paneEntry.text || "") : ""

      Component.onCompleted: {
        editor.text = pane.original
        editor.forceActiveFocus()
        editor.cursorPosition = editor.length
      }

      Text {
        id: kicker

        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        text: "Editing selected text"
        color: Color.menu.text
        opacity: 0.58
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
      }

      Flickable {
        id: scroll

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: kicker.bottom
        anchors.topMargin: Style.spacing.sm
        anchors.bottom: footer.top
        anchors.bottomMargin: Style.spacing.md
        contentWidth: width
        contentHeight: editor.contentHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        TextEdit {
          id: editor

          width: scroll.width
          textFormat: TextEdit.PlainText
          color: Color.menu.text
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.title
          wrapMode: TextEdit.WrapAnywhere
          selectByMouse: true
          selectionColor: Color.menu.selectedBackground
          selectedTextColor: Color.menu.selectedText

          // Flickable does not follow the caret on its own, so a long entry
          // would type off the bottom of the pane.
          onCursorRectangleChanged: {
            if (cursorRectangle.y < scroll.contentY)
              scroll.contentY = cursorRectangle.y
            else if (cursorRectangle.y + cursorRectangle.height > scroll.contentY + scroll.height)
              scroll.contentY = cursorRectangle.y + cursorRectangle.height - scroll.height
          }

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              root.cancel()
              event.accepted = true
            } else if ((event.modifiers & Qt.ControlModifier)
                && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
              root.save(editor.text)
              event.accepted = true
            }
          }
        }
      }

      Item {
        id: footer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.max(hint.implicitHeight, buttons.implicitHeight)

        Text {
          id: hint

          textFormat: Text.PlainText
          anchors.left: parent.left
          anchors.right: buttons.left
          anchors.rightMargin: Style.spacing.controlGap
          anchors.verticalCenter: parent.verticalCenter
          text: editor.length > 0 ? "Original kept" : "Enter text to copy"
          color: Color.menu.text
          opacity: 0.55
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }

        Row {
          id: buttons

          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.spacing.controlGap

          Button {
            text: "Cancel  Esc"
            foreground: Color.menu.text
            fontFamily: Style.font.menuFamily
            fontSize: Style.font.body
            onClicked: root.cancel()
          }

          Button {
            text: "Copy new  Ctrl+Enter"
            bordered: true
            enabled: editor.length > 0 && !copyProcess.running
            opacity: enabled ? 1 : 0.45
            foreground: Color.menu.text
            fontFamily: Style.font.menuFamily
            fontSize: Style.font.body
            onClicked: root.save(editor.text)
          }
        }
      }
    }
  }
}
