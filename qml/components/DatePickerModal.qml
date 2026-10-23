import QtQuick
import QtQuick.Layouts
import Felgo
import "."

AppModal {
  id: root
  property real availableHeight: dp(700)
  property date selectedDate: new Date()
  signal dateSelected(date selectedDate)

  function openForDate(date) {
    root.selectedDate = date
    datePicker.setDate(date)
    root.open()
  }

  fullscreen: false
  modalHeight: Math.min(dp(272) + NativeUtils.safeAreaInsets.bottom,
                        root.availableHeight * 0.9)
  closeOnBackgroundClick: true
  closeWithBackButton: true
  onClosed: datePicker.setDate(root.selectedDate)

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: dp(12)
    anchors.bottomMargin: dp(12) + NativeUtils.safeAreaInsets.bottom
    spacing: dp(4)

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: dp(48)

      StyledButton {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: dp(80)
        text: qsTr("Cancel")
        flat: true
        onClicked: root.close()
      }

      StyledText {
        anchors.centerIn: parent
        text: qsTr("Select date")
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
      }

      StyledButton {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: dp(80)
        text: qsTr("Done")
        flat: true
        fontBold: true
        enabled: !datePicker.isMoving
        onClicked: {
          root.selectedDate = datePicker.selectedDate
          root.dateSelected(root.selectedDate)
          root.close()
        }
      }
    }

    DatePicker {
      id: datePicker
      Layout.fillWidth: true
      Layout.preferredHeight: dp(200)
      datePickerMode: dateMode
      useCombinedDate: false
      dateFormat: "yyyy MMM dd"
      endDate: new Date()
      // Felgo's wheel transform is designed around the default eleven items.
      visibleItemCount: 11
      yearTumbler: ({ width: datePicker.width / 3 })
      monthTumbler: ({ width: datePicker.width / 3 })
      dayTumbler: ({ width: datePicker.width / 3 })
      itemDelegate: Component {
        StyledText {
          anchors.centerIn: parent
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          font.pixelSize: sp(22)
          text: parent && parent.tumbler
                ? parent.tumbler.formatDelegateText(parent.itemIndex, parent.itemData) : ""
        }
      }
    }
  }
}
