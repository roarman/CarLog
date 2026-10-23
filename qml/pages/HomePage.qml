import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"

AppPage {
  id: root
  title: qsTr("Home")
  property var fuelRecords: dataModel.fuelRecords
  signal addFuelRecordRequested()

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(16)

    RowLayout {
      Layout.fillWidth: true
      StyledText {
        Layout.fillWidth: true
        text: dataModel.carName
        font.pixelSize: sp(24)
        font.bold: true
        elide: Text.ElideRight
      }
      StyledButton {
        text: qsTr("Reset")
        flat: true
        onClicked: logic.onboardingReset()
      }
    }

    StyledText {
      text: qsTr("Fuel records")
      font.pixelSize: sp(20)
      font.bold: true
    }

    StyledButton {
      Layout.fillWidth: true
      text: qsTr("Add fuel record")
      onClicked: root.addFuelRecordRequested()
    }

    StyledText {
      Layout.fillWidth: true
      visible: dataModel.fuelRecordsError.length > 0
      text: dataModel.fuelRecordsError
      color: "#b83232"
      wrapMode: Text.WordWrap
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: dp(8)
        visible: recordsList.count === 0 && !dataModel.fuelRecordsError
        StyledText {
          width: parent.width
          text: qsTr("No fuel records yet")
          horizontalAlignment: Text.AlignHCenter
          font.bold: true
        }
        StyledText {
          width: parent.width
          text: qsTr("Keep track of your refuelling here.")
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          color: "#666666"
        }
      }

      ListView {
        id: recordsList
        anchors.fill: parent
        clip: true
        spacing: 0
        model: root.fuelRecords
        delegate: Item {
          width: recordsList.width
          height: recordContent.implicitHeight + dp(32) + px(1)

          ColumnLayout {
            id: recordContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: dp(16)
            spacing: dp(6)

            RowLayout {
              Layout.fillWidth: true
              spacing: dp(16)
              StyledText {
                id: recordDate
                Layout.fillWidth: true
                text: modelData.date
                font.pixelSize: sp(16)
                elide: Text.ElideRight
              }
              StyledText {
                id: recordAmount
                Layout.maximumWidth: recordContent.width * 0.5
                text: modelData.totalCost + " €"
                horizontalAlignment: Text.AlignRight
                font.pixelSize: sp(18)
                font.bold: true
                elide: Text.ElideLeft
              }
            }
            StyledText {
              id: recordDetails
              Layout.fillWidth: true
              text: qsTr("%1 km · %2 L")
                    .arg(modelData.mileage)
                    .arg(modelData.liters)
              font.pixelSize: sp(14)
              color: Theme.colors.textColor
              opacity: 0.65
              wrapMode: Text.WordWrap
            }
          }

          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: px(1)
            color: Theme.dividerColor
          }
        }
      }
    }
  }
}
