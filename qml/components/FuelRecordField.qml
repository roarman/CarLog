import QtQuick
import QtQuick.Layouts
import Felgo
import "../design"

ColumnLayout {
  id: root
  property string label: ""
  property alias text: field.text
  property alias placeholderText: field.placeholderText
  property alias inputMethodHints: field.inputMethodHints
  property alias readOnly: field.readOnly
  property alias clickEnabled: field.clickEnabled
  property string errorText: ""
  signal textEdited()
  signal clicked()

  spacing: dp(6)

  StyledText {
    text: label
  }

  StyledTextField {
    id: field
    Layout.fillWidth: true
    backgroundColor: Design.inputBackgroundColor
    onClicked: root.clicked()
    onTextEdited: root.textEdited()
    borderColor: root.errorText ? Theme.colors.tintColor : Theme.dividerColor
  }

  StyledText {
    Layout.fillWidth: true
    visible: root.errorText.length > 0
    text: root.errorText
    color: Theme.colors.tintColor
    font.pixelSize: sp(13)
    wrapMode: Text.WordWrap
  }
}
