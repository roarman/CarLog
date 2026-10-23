import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"
import "../logic/FuelRecordValidation.js" as FuelRecordValidation

AppPage {
  id: root
  title: isEditing ? qsTr("Edit fuel record") : qsTr("Add fuel record")
  property var recordToEdit: null
  readonly property bool isEditing: recordToEdit !== null
  property bool isDeleting: false
  property bool isSaving: false
  property bool isSubmitted: false
  property bool isConfirmingDelete: false
  readonly property bool isBusy: isSaving || isDeleting || isConfirmingDelete || isSubmitted
  property bool isShowValidationErrors: false
  property date selectedDate: new Date()
  property string saveError: ""
  readonly property var draft: ({
    date: Qt.formatDate(selectedDate, "yyyy-MM-dd"),
    mileage: odometerField.text,
    liters: fuelField.text,
    totalCost: costField.text
  })
  readonly property var validation: FuelRecordValidation.validate(draft)
  signal saved()
  signal deleted()

  Component.onCompleted: {
    if (!isEditing)
      return
    selectedDate = new Date(recordToEdit.date + "T00:00:00")
    odometerField.text = String(recordToEdit.mileage)
    fuelField.text = String(recordToEdit.liters)
    costField.text = String(recordToEdit.totalCost)
  }

  // Ask before dispatching deletion. Cancelling leaves the record unchanged.
  function confirmDelete() {
    if (!isEditing || isBusy)
      return
    isConfirmingDelete = true
    Qt.inputMethod.hide()
    NativeDialog.confirm(qsTr("Delete fuel record?"),
                         qsTr("This record will be permanently deleted."), function(confirmed) {
      if (!root || !root.isConfirmingDelete)
        return
      root.isConfirmingDelete = false
      if (!confirmed)
        return
      root.saveError = ""
      root.isDeleting = true
      logic.deleteFuelRecord(root.recordToEdit.id)
    }, true)
  }

  function submitRecord() {
    if (isBusy)
      return
    isShowValidationErrors = true
    saveError = ""
    if (!validation.valid)
      return
    isSaving = true
    if (isEditing)
      logic.updateFuelRecord(recordToEdit.id, draft)
    else
      logic.addFuelRecord(draft)
  }

  Connections {
    target: dataModel
    function onFuelRecordDeleted() {
      if (!root.isDeleting)
        return
      root.isSubmitted = true
      root.isDeleting = false
      root.deleted()
    }
    function onFuelRecordDeleteFailed(message) {
      if (!root.isDeleting)
        return
      root.isDeleting = false
      root.saveError = message
    }
    function onFuelRecordSaved() {
      if (!root.isSaving)
        return
      root.isSubmitted = true
      root.isSaving = false
      root.saved()
    }
    function onFuelRecordSaveFailed(errors, message) {
      if (!root.isSaving)
        return
      root.isSaving = false
      root.isShowValidationErrors = true
      root.saveError = message
    }
  }

  onPopped: {
    isConfirmingDelete = false
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
      enabled: !root.isBusy

      FuelRecordField {
        id: dateField
        Layout.fillWidth: true
        label: qsTr("Date")
        text: Qt.formatDate(root.selectedDate, "yyyy-MM-dd")
        placeholderText: "YYYY-MM-DD"
        readOnly: true
        clickEnabled: true
        errorText: root.isShowValidationErrors ? (root.validation.errors.date || "") : ""
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
        errorText: root.isShowValidationErrors ? (root.validation.errors.mileage || "") : ""
      }
      FuelRecordField {
        id: fuelField
        Layout.fillWidth: true
        label: qsTr("Fuel added (L)")
        placeholderText: qsTr("e.g. 35.5")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        errorText: root.isShowValidationErrors ? (root.validation.errors.liters || "") : ""
      }
      FuelRecordField {
        id: costField
        Layout.fillWidth: true
        label: qsTr("Total cost (€)")
        placeholderText: qsTr("e.g. 62.50")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        errorText: root.isShowValidationErrors ? (root.validation.errors.totalCost || "") : ""
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
    height: actionButtons.implicitHeight + dp(32)
    color: Theme.colors.backgroundColor

    Rectangle {
      width: parent.width
      height: px(1)
      color: Theme.dividerColor
    }
    ColumnLayout {
      id: actionButtons
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(20)
      anchors.verticalCenter: parent.verticalCenter
      spacing: dp(8)
      enabled: !root.isBusy

      StyledButton {
        id: saveButton
        Layout.fillWidth: true
        text: root.isSaving ? qsTr("Saving…") : qsTr("Save fuel record")
        onClicked: root.submitRecord()
      }
      StyledButton {
        Layout.fillWidth: true
        visible: root.isEditing
        text: root.isDeleting ? qsTr("Deleting…") : qsTr("Delete fuel record")
        flat: true
        onClicked: root.confirmDelete()
      }
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
