import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"
import "../logic/FuelRecordValidation.js" as FuelRecordValidation

AppPage {
  id: root
  title: qsTr("Add fuel record")
  property date selectedDate: new Date()
  property bool showValidationErrors: false
  property bool saving: false
  property bool submitted: false
  property string saveError: ""
  readonly property var draft: ({
    date: Qt.formatDate(selectedDate, "yyyy-MM-dd"),
    mileage: odometerField.text,
    liters: fuelField.text,
    totalCost: costField.text
  })
  readonly property var validation: FuelRecordValidation.validate(draft)
  signal saved()

  function submitRecord() {
    if (saving || submitted)
      return
    showValidationErrors = true
    saveError = ""
    if (!validation.valid)
      return
    saving = true
    logic.addFuelRecord(draft)
  }

  Connections {
    target: dataModel
    function onFuelRecordSaved() {
      if (!root.saving)
        return
      root.submitted = true
      root.saving = false
      root.saved()
    }
    function onFuelRecordSaveFailed(errors, message) {
      if (!root.saving)
        return
      root.saving = false
      root.showValidationErrors = true
      root.saveError = message
    }
  }
  onPopped: {
    datePickerModal.close()
    Qt.inputMethod.hide()
  }

  AppFlickable {
    id: formScroll
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: saveBar.top
    contentWidth: width
    contentHeight: form.implicitHeight + dp(40)
    clip: true

    ColumnLayout {
      id: form
      x: dp(20)
      y: dp(20)
      width: parent.width - dp(40)
      spacing: dp(16)
      enabled: !root.saving && !root.submitted

      FuelRecordField {
        id: dateField
        Layout.fillWidth: true
        label: qsTr("Date")
        text: Qt.formatDate(root.selectedDate, "yyyy-MM-dd")
        placeholderText: "YYYY-MM-DD"
        readOnly: true
        clickEnabled: true
        errorText: root.showValidationErrors ? (root.validation.errors.date || "") : ""
        onClicked: {
          Qt.inputMethod.hide()
          datePickerModal.openForDate(root.selectedDate)
        }
      }
      FuelRecordField {
        id: odometerField
        Layout.fillWidth: true
        label: qsTr("Odometer (km)")
        placeholderText: qsTr("e.g. 42500")
        inputMethodHints: Qt.ImhDigitsOnly
        errorText: root.showValidationErrors ? (root.validation.errors.mileage || "") : ""
      }
      FuelRecordField {
        id: fuelField
        Layout.fillWidth: true
        label: qsTr("Fuel added (L)")
        placeholderText: qsTr("e.g. 35.5")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        errorText: root.showValidationErrors ? (root.validation.errors.liters || "") : ""
      }
      FuelRecordField {
        id: costField
        Layout.fillWidth: true
        label: qsTr("Total cost (€)")
        placeholderText: qsTr("e.g. 62.50")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        errorText: root.showValidationErrors ? (root.validation.errors.totalCost || "") : ""
      }
      StyledText {
        Layout.fillWidth: true
        visible: root.saveError.length > 0
        text: root.saveError
        color: "#b83232"
        wrapMode: Text.WordWrap
      }
    }
  }

  Rectangle {
    id: saveBar
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: getApplication().keyboardHeight
    height: saveButton.implicitHeight + dp(32)
    color: Theme.colors.backgroundColor

    Rectangle {
      width: parent.width
      height: px(1)
      color: Theme.dividerColor
    }
    StyledButton {
      id: saveButton
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(20)
      anchors.verticalCenter: parent.verticalCenter
      text: root.saving ? qsTr("Saving…") : qsTr("Save fuel record")
      enabled: !root.saving && !root.submitted
      onClicked: root.submitRecord()
    }
  }

  DatePickerModal {
    id: datePickerModal
    availableHeight: root.height
    onDateSelected: function(date) {
      root.selectedDate = date
    }
  }
}
