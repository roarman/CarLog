import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Felgo
import "../design"
import "."

Item {
  id: root
  property string carName: ""
  property real entranceProgress: 1
  property real carOffset: 0
  signal resetRequested()

  implicitHeight: dp(180)

  Rectangle {
    id: vehicleCard
    anchors.fill: parent
    radius: dp(22)
    color: Design.vehicleCardBackgroundColor
    clip: true
    // A rectangular clip does not follow Rectangle.radius; mask the whole card.
    layer.enabled: true
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: Rectangle {
        // Keep the mask outside the effect's visual subtree.
        parent: vehicleCard.parent
        width: vehicleCard.width
        height: vehicleCard.height
        radius: vehicleCard.radius
        color: "white"
        visible: false
        layer.enabled: true
      }
    }
    readonly property real cardProgress: root.entranceProgress
    opacity: cardProgress
    transform: Translate { y: (1 - vehicleCard.cardProgress) * dp(56) }

    Item {
      id: carWindow
      width: parent.width * 0.53
      height: parent.height - dp(24)
      anchors.verticalCenter: parent.verticalCenter
      clip: true

      AppImage {
        id: carImage
        source: "../../assets/car.png"
        width: vehicleCard.width * 1.05
        height: width * 0.375
        x: carWindow.width - width
        anchors.verticalCenter: parent.verticalCenter
        fillMode: AppImage.PreserveAspectFit
        transform: Translate { x: root.carOffset }
      }
      Rectangle {
        anchors.right: parent.right
        width: dp(36)
        height: parent.height
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0; color: Qt.rgba(vehicleCard.color.r, vehicleCard.color.g, vehicleCard.color.b, 0) }
          GradientStop { position: 1; color: Design.vehicleCardBackgroundColor }
        }
      }
    }

    StyledButton {
      id: resetButton
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: dp(8)
      anchors.rightMargin: dp(12)
      height: dp(36)
      minimumHeight: dp(36)
      text: qsTr("Reset")
      flat: true
      textColor: Design.vehicleCardSecondaryTextColor
      textSize: sp(12)
      horizontalMargin: 0
      verticalMargin: 0
      onClicked: root.resetRequested()
    }

    ColumnLayout {
      anchors.left: carWindow.right
      anchors.leftMargin: dp(18)
      anchors.right: parent.right
      anchors.rightMargin: dp(18)
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: dp(12)
      spacing: dp(6)

      StyledText {
        Layout.fillWidth: true
        text: qsTr("Your car")
        color: Design.vehicleCardSecondaryTextColor
        font.pixelSize: sp(12)
      }
      StyledText {
        Layout.fillWidth: true
        text: root.carName
        color: Design.vehicleCardTextColor
        font.pixelSize: sp(24)
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }
    }
  }
}
