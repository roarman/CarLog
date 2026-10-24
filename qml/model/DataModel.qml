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
  signal fuelRecordDeleted()
  signal fuelRecordDeleteFailed(string message)
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

  // Give each record a stable identity independent of its date or list position.
  function createRecordId() {
    return Date.now().toString(36) + "-" + Math.random().toString(36).slice(2)
  }

  // Publish changes only after the synchronous Storage call succeeds.
  function storeFuelRecords(records) {
    lastStorageError = null
    storage.setValue("fuelRecords", records)
    // onStorageError sets lastStorageError during setValue(), before it returns.
    if (lastStorageError)
      return false
    fuelRecords = records
    return true
  }

  // Validate and save either a new record or changes to the selected record.
  function saveFuelRecord(draft, recordId) {
    const result = FuelRecordValidation.validate(draft)
    if (!result.valid) {
      fuelRecordSaveFailed(result.errors, "")
      return
    }
    if (fuelRecordsError) {
      fuelRecordSaveFailed({}, fuelRecordsError)
      return
    }

    const updated = fuelRecords.slice()
    if (recordId !== undefined) {
      const index = updated.findIndex(function(record) { return record.id === recordId })
      if (index < 0) {
        fuelRecordSaveFailed({}, qsTr("This record no longer exists. Go back and select another record."))
        return
      }
      updated[index] = {
        id: updated[index].id,
        date: result.record.date,
        mileage: result.record.mileage,
        liters: result.record.liters,
        totalCost: result.record.totalCost
      }
    } else {
      updated.unshift({
        id: createRecordId(),
        date: result.record.date,
        mileage: result.record.mileage,
        liters: result.record.liters,
        totalCost: result.record.totalCost
      })
    }
    updated.sort(function(a, b) { return b.date.localeCompare(a.date) })
    if (!storeFuelRecords(updated)) {
      fuelRecordSaveFailed({}, qsTr("Could not save the record. Your input has been kept. Please try again."))
      return
    }
    fuelRecordSaved()
  }

  // Delete only the selected record and keep the list unchanged if saving fails.
  function deleteFuelRecord(recordId) {
    if (fuelRecordsError) {
      fuelRecordDeleteFailed(fuelRecordsError)
      return
    }
    const updated = fuelRecords.filter(function(record) { return record.id !== recordId })
    if (updated.length === fuelRecords.length) {
      fuelRecordDeleteFailed(qsTr("This record no longer exists. Go back and select another record."))
      return
    }
    if (!storeFuelRecords(updated)) {
      fuelRecordDeleteFailed(qsTr("Could not delete the record. Please try again."))
      return
    }
    fuelRecordDeleted()
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

  // Clear registration and fuel records for a fresh start.
  function resetOnboarding() {
    storage.setValue("carName", "")
    storage.setValue("onboardingCompleted", false)
    storage.setValue("fuelRecords", [])
    root.carName = ""
    root.fuelRecords = []
    root.fuelRecordsError = ""
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

    function onUpdateFuelRecord(recordId, draft) {
      saveFuelRecord(draft, recordId)
    }

    function onDeleteFuelRecord(recordId) {
      deleteFuelRecord(recordId)
    }

    function onAddFuelRecord(draft) {
      saveFuelRecord(draft)
    }
  }

  Component.onCompleted: {
    prepare()
  }
}
