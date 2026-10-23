import QtQuick

Item {
  signal onboardingFinished(string carName)
  signal onboardingReset()
  signal addFuelRecord(var draft)
}
