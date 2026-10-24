import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"

AppPage {
  id: root
  title: qsTr("Home")
  backgroundColor: Theme.colors.backgroundColor
  property bool isEntranceReady: true
  property var fuelRecords: dataModel.fuelRecords
  property alias entranceProgress: cardEntrance.progress
  property real carOffset: -dp(400)
  signal addFuelRecordRequested()
  signal editFuelRecordRequested(var record)

  // Reset before the page is revealed, including when reusing it after onboarding.
  function resetEntrance() {
    entranceAnimation.stop()
    entranceProgress = 0
    carOffset = -Math.max(width, dp(400))
  }

  // Animate transforms so the layout keeps each card's final position.
  function playEntrance() {
    resetEntrance()
    if (isEntranceReady)
      entranceAnimation.restart()
  }

  onIsEntranceReadyChanged: {
    if (!isEntranceReady)
      resetEntrance()
  }

  onAppeared: playEntrance()
  onDisappeared: entranceAnimation.stop()

  ParallelAnimation {
    id: entranceAnimation
    SlideInAnimation { id: cardEntrance }
    SequentialAnimation {
      PauseAnimation { duration: 180 }
      NumberAnimation {
        target: root
        property: "carOffset"
        from: -Math.max(root.width, dp(400))
        to: 0
        duration: 650
        easing.type: Easing.OutCubic
      }
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(18)

    VehicleCard {
      id: vehicleCard
      Layout.fillWidth: true
      Layout.preferredHeight: dp(180)
      carName: dataModel.carName
      entranceProgress: cardEntrance.progressForCard(0)
      carOffset: root.carOffset
      onResetRequested: logic.onboardingReset()
    }

    RowLayout {
      id: recordActions
      Layout.fillWidth: true
      spacing: dp(12)
      readonly property real cardProgress: cardEntrance.progressForCard(1)
      opacity: cardProgress
      transform: Translate { y: (1 - recordActions.cardProgress) * dp(40) }

      StyledText {
        Layout.fillWidth: true
        text: qsTr("Fuel records")
        color: Theme.listItem.textColor
        font.pixelSize: sp(22)
        font.weight: Font.DemiBold
      }
      StyledButton {
        id: addRecordButton
        Layout.preferredWidth: dp(52)
        Layout.preferredHeight: dp(52)
        minimumWidth: dp(52)
        minimumHeight: dp(52)
        horizontalMargin: 0
        verticalMargin: 0
        radius: dp(18)
        iconType: IconType.plus
        iconSize: sp(20)
        textColor: Theme.listItem.backgroundColor
        backgroundColor: Theme.colors.tintColor
        backgroundColorPressed: Theme.appButton.backgroundColorPressed
        borderWidth: 0
        background: Rectangle {
          radius: dp(18)
          color: addRecordButton.pressed ? addRecordButton.backgroundColorPressed
                                         : addRecordButton.backgroundColor
        }
        Accessible.name: qsTr("Add fuel record")
        Accessible.role: Accessible.Button
        onClicked: root.addFuelRecordRequested()
      }
    }

    FuelRecordsList {
      id: recordsList
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: dp(18)
      records: root.fuelRecords
      editable: true
      entranceAnimation: cardEntrance
      emptyDescription: qsTr("Tap + to add your first fuel record.")
      emptyOpacity: root.entranceProgress
      errorMessage: dataModel.fuelRecordsError
      onRecordClicked: function(record) { root.editFuelRecordRequested(record) }
    }
  }
}
