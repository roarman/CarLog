import Felgo
import QtQuick
import "../logic/FuelRecordValidation.js" as FuelRecordValidation

Item {
  id: root

  // property to configure target dispatcher / logic
  property alias dispatcher: logicConnection.target

  property string carName: ""
  property bool onboardingCompleted: false
  property var fuelRecords: []
  property string fuelRecordsError: ""
  property var lastStorageError: null
  signal fuelRecordSaved()
  signal fuelRecordSaveFailed(var errors, string message)

  function prepare() {
    carName = storage.getValue("carName") || ""
    onboardingCompleted = !!storage.getValue("onboardingCompleted")
    loadFuelRecords()
  }

  // Load saved fuel records, or use an empty list on first launch.
  function loadFuelRecords() {
    // Clear any error from the previous operation.
    lastStorageError = null
    const records = storage.getValue("fuelRecords")
    const isMissing = records === null || records === undefined
    if (isMissing) {
      fuelRecords = []
      fuelRecordsError = ""
      return
    }

    // getValue() runs synchronously. If it emits storageError, onStorageError
    // sets lastStorageError before getValue() returns, so we can check it below.
    if (lastStorageError) {
      fuelRecordsError = qsTr("Fuel records could not be loaded. Restart the app to try again.")
      return
    }

    fuelRecords = records
    fuelRecordsError = ""
  }

  // Validate and save a new record, then update the list and notify the page.
  function saveFuelRecord(draft) {
    const result = FuelRecordValidation.validate(draft)
    if (!result.valid) {
      fuelRecordSaveFailed(result.errors, "")
      return
    }
    if (fuelRecordsError) {
      fuelRecordSaveFailed({}, fuelRecordsError)
      return
    }

    const updated = [result.record].concat(fuelRecords)
    updated.sort(function(a, b) {
      return b.date.localeCompare(a.date)
    })
    const errorMessage = qsTr("Could not save the record. Your input has been kept. Please try again.")
    lastStorageError = null
    storage.setValue("fuelRecords", updated)
    // setValue() runs synchronously.
    if (lastStorageError) {
      fuelRecordSaveFailed({}, errorMessage)
      return
    }
    fuelRecords = updated
    fuelRecordSaved()
  }

  Connections {
    target: storage
    function onStorageError(errorData) {
      // Capture errors emitted during the current Storage call.
      root.lastStorageError = errorData
    }
  }

  function completeOnboarding(name) {
    const trimmedName = name.trim()
    if (trimmedName.length === 0)
      return false

    storage.setValue("carName", trimmedName)
    storage.setValue("onboardingCompleted", true)
    root.carName = trimmedName
    root.onboardingCompleted = true
    return true
  }

  // For Testing
  function resetOnboarding() {
    storage.setValue("carName", "")
    storage.setValue("onboardingCompleted", false)
    root.carName = ""
    root.onboardingCompleted = false
  }

  // listen to actions from dispatcher
  Connections {
    id: logicConnection

    function onOnboardingFinished(carName) {
      completeOnboarding(carName)
    }

    function onOnboardingReset() {
      resetOnboarding()
    }

    function onAddFuelRecord(draft) {
      saveFuelRecord(draft)
    }
  }

  Component.onCompleted: {
    prepare()
  }
}
