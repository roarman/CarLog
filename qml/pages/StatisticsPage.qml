import QtQuick
import QtQuick.Layouts
import Felgo
import "../components"

AppPage {
  id: root
  title: qsTr("Statistics")
  backgroundColor: Theme.colors.backgroundColor
  property alias entranceProgress: cardEntrance.progress
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

  function playEntrance() {
    cardEntrance.stop()
    cardEntrance.progress = 0
    cardEntrance.restart()
  }

  onAppeared: playEntrance()
  onDisappeared: cardEntrance.stop()
  onPopped: datePickerModal.close()

  SlideInAnimation { id: cardEntrance }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: dp(20)
    spacing: dp(16)

    Rectangle {
      id: periodCard
      Layout.fillWidth: true
      readonly property real cardProgress: cardEntrance.progressForCard(0)
      opacity: cardProgress
      transform: Translate { y: (1 - periodCard.cardProgress) * dp(56) }
      implicitHeight: periodContent.implicitHeight + dp(32)
      radius: dp(18)
      color: Theme.listItem.backgroundColor
      border.color: Theme.listItem.dividerColor
      border.width: px(1)

      ColumnLayout {
        id: periodContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: dp(16)
        spacing: dp(12)

        StyledText {
          text: qsTr("Period")
          color: Theme.listItem.textColor
          font.pixelSize: sp(18)
          font.weight: Font.DemiBold
        }
        RowLayout {
          Layout.fillWidth: true
          spacing: dp(8)
          StyledButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            minimumWidth: 0
            horizontalMargin: 0
            verticalMargin: 0
            text: qsTr("All time")
            textSize: sp(14)
            textColor: root.isAllTime ? Theme.colors.tintColor : Theme.listItem.detailTextColor
            fontBold: root.isAllTime
            background: Rectangle {
              radius: dp(10)
              color: root.isAllTime ? Theme.listItem.activeBackgroundColor : Theme.colors.backgroundColor
            }
            onClicked: root.isAllTime = true
          }
          StyledButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            minimumWidth: 0
            horizontalMargin: 0
            verticalMargin: 0
            text: qsTr("This month")
            textSize: sp(14)
            textColor: root.isThisMonth ? Theme.colors.tintColor : Theme.listItem.detailTextColor
            fontBold: root.isThisMonth
            background: Rectangle {
              radius: dp(10)
              color: root.isThisMonth ? Theme.listItem.activeBackgroundColor : Theme.colors.backgroundColor
            }
            onClicked: root.showThisMonth()
          }
        }
        RowLayout {
          Layout.fillWidth: true
          spacing: dp(12)
          ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            spacing: dp(6)
            StyledText {
              text: qsTr("From")
              color: Theme.listItem.detailTextColor
              font.pixelSize: sp(12)
            }
            StyledButton {
              Layout.fillWidth: true
              minimumWidth: 0
              horizontalMargin: 0
              verticalMargin: 0
              horizontalPadding: dp(6)
              text: root.isAllTime ? qsTr("All dates") : root.startDateText
              textSize: sp(13)
              textColor: Theme.listItem.textColor
              background: Rectangle { radius: dp(10); color: Theme.colors.backgroundColor }
              Accessible.name: qsTr("Start date")
              onClicked: root.selectDate(true)
            }
          }
          ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            spacing: dp(6)
            StyledText {
              text: qsTr("To")
              color: Theme.listItem.detailTextColor
              font.pixelSize: sp(12)
            }
            StyledButton {
              Layout.fillWidth: true
              minimumWidth: 0
              horizontalMargin: 0
              verticalMargin: 0
              horizontalPadding: dp(6)
              text: root.isAllTime ? qsTr("All dates") : root.endDateText
              textSize: sp(13)
              textColor: Theme.listItem.textColor
              background: Rectangle { radius: dp(10); color: Theme.colors.backgroundColor }
              Accessible.name: qsTr("End date")
              onClicked: root.selectDate(false)
            }
          }
        }
      }
    }

    Rectangle {
      id: summaryCard
      Layout.fillWidth: true
      visible: root.isValidPeriod && !dataModel.fuelRecordsError
      readonly property real cardProgress: cardEntrance.progressForCard(1)
      opacity: cardProgress
      transform: Translate { y: (1 - summaryCard.cardProgress) * dp(64) }
      implicitHeight: summaryContent.implicitHeight + dp(32)
      radius: dp(18)
      color: Theme.listItem.backgroundColor
      border.color: Theme.listItem.dividerColor
      border.width: px(1)

      ColumnLayout {
        id: summaryContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: dp(16)
        spacing: dp(10)

        StyledText {
          text: qsTr("Overview")
          color: Theme.listItem.textColor
          font.pixelSize: sp(18)
          font.weight: Font.DemiBold
        }
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
              color: Theme.listItem.detailTextColor
              font.pixelSize: sp(14)
            }
            StyledText {
              text: modelData.value
              color: Theme.listItem.textColor
              font.pixelSize: sp(18)
              font.weight: Font.DemiBold
            }
          }
        }
      }
    }

    FuelRecordsList {
      id: recordsList
      Layout.fillWidth: true
      Layout.fillHeight: true
      records: root.filteredRecords
      entranceAnimation: cardEntrance
      emptyTitle: qsTr("No fuel records in this period")
      errorMessage: dataModel.fuelRecordsError
                    || (!root.isValidPeriod ? qsTr("Start date must be on or before end date.") : "")
      recordsVisible: root.isValidPeriod && !dataModel.fuelRecordsError
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
