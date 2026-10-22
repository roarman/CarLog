import Felgo
import QtQuick
import QtQuick.Layouts
import "../design"

AppTextField {
  id: control
  borderWidth: 1
  radius: dp(Design.radius)
  inputMode: inputModeDefault

  Layout.leftMargin: dp(Design.horizontalMargin)
  Layout.rightMargin: dp(Design.horizontalMargin)
  Layout.topMargin: dp(Design.verticalMargin)
  Layout.bottomMargin: dp(Design.verticalMargin)

  anchors.leftMargin: dp(Design.horizontalMargin)
  anchors.rightMargin: dp(Design.horizontalMargin)
  anchors.topMargin: dp(Design.verticalMargin)
  anchors.bottomMargin: dp(Design.verticalMargin)
}
