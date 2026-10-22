import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"

AppPage {
  title: qsTr("Home")

  ColumnLayout {
    anchors.centerIn: parent
    spacing: dp(10)

    StyledText {
      text: dataModel.carName
    }

    StyledButton {
      text: qsTr("Reset")
      onClicked: {
        logic.onboardingReset()
      }
    }
  }
}
