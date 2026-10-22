import Felgo
import QtQuick
import QtQuick.Layouts
import "../components"

AppPage {
  id: root

  Column {
    id: column
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(10)

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
    }

    RowLayout {
      width: parent.width
      spacing: dp(10)

      StyledText {
        text: "Car Name"
      }

      StyledTextField {
        Layout.fillWidth: true
        placeholderText: "Edit text here"
        width: dp(200)
      }
    }

    StyledButton {
      width: parent.width
      text: qsTr("Register your car")
      onClicked: {

      }
    }
  }
}
