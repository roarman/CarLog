import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"

AppPage {
  id: root
  title: qsTr("Statistics")
  property bool isAllTime: false
  property bool isSelectingStartDate: true
  readonly property bool isThisMonth: !isAllTime
    && startDateText === Qt.formatDate(new Date(new Date().getFullYear(), new Date().getMonth(), 1), "yyyy-MM-dd")
    && endDateText === Qt.formatDate(new Date(), "yyyy-MM-dd")
  readonly property bool isValidPeriod: isAllTime || startDateText <= endDateText
  property date startDate: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
  property date endDate: new Date()
  readonly property string startDateText: Qt.formatDate(startDate, "yyyy-MM-dd")
  readonly property string endDateText: Qt.formatDate(endDate, "yyyy-MM-dd")
  readonly property var filteredRecords: filterRecords(dataModel.fuelRecords, isAllTime,
                                                      startDateText, endDateText)
  readonly property var totals: calculateTotals(filteredRecords)

  // ISO dates can be compared directly; include both ends of the selected period.
  function filterRecords(records, includeAll, fromDate, toDate) {
    if (includeAll)
      return records
    return records.filter(function(record) {
      return record.date >= fromDate && record.date <= toDate
    })
  }

  // Derive totals from the visible records instead of storing another copy.
  function calculateTotals(records) {
    let liters = 0
    let cost = 0
    for (let record of records) {
      liters += record.liters
      cost += record.totalCost
    }
    return {liters: liters, cost: cost}
  }

  function showThisMonth() {
    const today = new Date()
    startDate = new Date(today.getFullYear(), today.getMonth(), 1)
    endDate = today
    isAllTime = false
  }

  function selectDate(isStart) {
    isSelectingStartDate = isStart
    datePickerModal.openForDate(isStart ? startDate : endDate)
  }

  onPopped: datePickerModal.close()

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(16)

    RowLayout {
      Layout.fillWidth: true
      StyledButton {
        Layout.fillWidth: true
        text: qsTr("All time")
        flat: true
        fontBold: root.isAllTime
        textColor: root.isAllTime ? Theme.colors.tintColor : Theme.colors.textColor
        onClicked: root.isAllTime = true
      }
      StyledButton {
        Layout.fillWidth: true
        text: qsTr("This month")
        flat: true
        fontBold: root.isThisMonth
        textColor: root.isThisMonth ? Theme.colors.tintColor : Theme.colors.textColor
        onClicked: root.showThisMonth()
      }
    }

    FuelRecordField {
      Layout.fillWidth: true
      label: qsTr("From")
      text: root.isAllTime ? qsTr("All dates") : root.startDateText
      readOnly: true
      clickEnabled: true
      onClicked: root.selectDate(true)
    }

    FuelRecordField {
      Layout.fillWidth: true
      label: qsTr("To")
      text: root.isAllTime ? qsTr("All dates") : root.endDateText
      readOnly: true
      clickEnabled: true
      onClicked: root.selectDate(false)
    }

    StyledText {
      Layout.fillWidth: true
      visible: !root.isValidPeriod || dataModel.fuelRecordsError.length > 0
      text: dataModel.fuelRecordsError || qsTr("Start date must be on or before end date.")
      color: "#b83232"
      wrapMode: Text.WordWrap
    }

    ColumnLayout {
      Layout.fillWidth: true
      visible: root.isValidPeriod && !dataModel.fuelRecordsError
      spacing: dp(8)

      Repeater {
        model: [
          {label: qsTr("Records"), value: String(root.filteredRecords.length)},
          {label: qsTr("Fuel added"), value: root.totals.liters.toFixed(2) + " L"},
          {label: qsTr("Total cost"), value: root.totals.cost.toFixed(2) + " €"}
        ]
        RowLayout {
          Layout.fillWidth: true
          spacing: dp(12)
          StyledText {
            Layout.fillWidth: true
            text: modelData.label
            font.pixelSize: sp(14)
            opacity: 0.65
          }
          StyledText {
            text: modelData.value
            font.pixelSize: sp(18)
            font.bold: true
          }
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.isValidPeriod && !dataModel.fuelRecordsError

      StyledText {
        anchors.centerIn: parent
        width: parent.width
        visible: root.filteredRecords.length === 0
        text: qsTr("No fuel records in this period")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
      }

      ListView {
        id: recordsList
        anchors.fill: parent
        clip: true
        model: root.filteredRecords
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
              StyledText {
                Layout.fillWidth: true
                text: modelData.date
                font.pixelSize: sp(16)
                elide: Text.ElideRight
              }
              StyledText {
                Layout.maximumWidth: recordContent.width * 0.5
                text: modelData.totalCost + " €"
                font.pixelSize: sp(18)
                font.bold: true
                elide: Text.ElideLeft
              }
            }
            StyledText {
              Layout.fillWidth: true
              text: qsTr("%1 km · %2 L").arg(modelData.mileage).arg(modelData.liters)
              font.pixelSize: sp(14)
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

  DatePickerModal {
    id: datePickerModal
    availableHeight: root.height
    onDateSelected: function(date) {
      if (root.isSelectingStartDate)
        root.startDate = date
      else
        root.endDate = date
      root.isAllTime = false
    }
  }
}
