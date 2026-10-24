import QtQuick
import QtQuick.Layouts
import Felgo
import "../design"
import "../components"

AppPage {
  id: root
  navigationBarHidden: true

  signal onboardingFinished(string carName)

  property TransitionOverlay transitionOverlay: null
  property bool departureRunning: false
  property string pendingCarName: ""

  function resetForm() {
    carNameField.clear()
  }

  function revealMainPage() {
    root.transitionOverlay.reveal()
  }

  Connections {
    target: root.transitionOverlay

    function onCovered() {
      root.onboardingFinished(root.pendingCarName)
    }

    function onFinished() {
      root.pendingCarName = ""
      root.departureRunning = false
      carTranslation.x = 0
    }
  }

  Column {
    id: column
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(10)
    enabled: !root.departureRunning

    // Spacer
    Item {
      width: 1
      height: dp(40)
    }

    AppText {
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: sp(24)
      font.bold: true
      text: qsTr("WELCOME TO CAR LOG")
    }

    AppImage {
      id: carImage
      anchors.horizontalCenter: parent.horizontalCenter
      source: "../../assets/car.png"
      width: parent.width * 0.7
      height: width * 0.7

      fillMode: AppImage.PreserveAspectFit
      transform: Translate { id: carTranslation }
    }

    RowLayout {
      width: parent.width
      spacing: dp(10)

      StyledText {
        text: "Car Name"
      }

      StyledTextField {
        id: carNameField
        Layout.fillWidth: true
        backgroundColor: Design.inputBackgroundColor
        placeholderText: "Edit text here"
        width: dp(200)
      }
    }

    StyledButton {
      width: parent.width
      text: qsTr("Register your car")
      enabled: carNameField.text.trim().length > 0
      onClicked: {
        if (root.departureRunning || !root.transitionOverlay || root.transitionOverlay.running
            || carNameField.text.trim().length === 0)
          return

        root.pendingCarName = carNameField.text.trim()
        root.departureRunning = true
        carDeparture.start()
        root.transitionOverlay.start()
      }
    }
  }

  NumberAnimation {
    id: carDeparture
    target: carTranslation
    property: "x"
    from: 0
    to: root.width + carImage.width
    duration: 450
    easing.type: Easing.InCubic
  }
}
