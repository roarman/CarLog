import Felgo
import QtQuick

Item {
  id: root

  property bool onboardingCompleted: false

  function prepare() {
    onboardingCompleted = !!storage.getValue("onboardingCompleted")
  }

  Component.onCompleted: {
    prepare()
  }
}
