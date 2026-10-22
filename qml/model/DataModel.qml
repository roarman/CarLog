import Felgo
import QtQuick

Item {
  id: root

  // property to configure target dispatcher / logic
  property alias dispatcher: logicConnection.target

  property string carName: ""
  property bool onboardingCompleted: false

  function prepare() {
    carName = storage.getValue("carName") || ""
    onboardingCompleted = !!storage.getValue("onboardingCompleted")
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
  }

  Component.onCompleted: {
    prepare()
  }
}
