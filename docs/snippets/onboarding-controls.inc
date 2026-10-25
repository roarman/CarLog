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
      onClicked: root.onboardingFinished(carNameField.text.trim())
    }
