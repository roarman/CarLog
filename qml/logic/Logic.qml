import QtQuick

Item {
  signal onboardingFinished(string carName)
  signal onboardingReset()
  signal addFuelRecord(var draft)
  signal updateFuelRecord(var recordId, var draft)
  signal deleteFuelRecord(var recordId)
}
