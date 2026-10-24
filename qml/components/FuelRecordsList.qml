import QtQuick
import QtQuick.Layouts
import Felgo

ColumnLayout {
  id: root
  property var records: []
  property bool editable: false
  property SlideInAnimation entranceAnimation: null
  property string emptyTitle: qsTr("No fuel records yet")
  property string emptyDescription: ""
  property string errorMessage: ""
  property bool recordsVisible: true
  property real emptyOpacity: 1
  readonly property int count: recordsView.count
  signal recordClicked(var record)

  spacing: dp(16)

  StyledText {
    Layout.fillWidth: true
    visible: root.errorMessage.length > 0
    text: root.errorMessage
    color: Theme.colors.tintColor
    wrapMode: Text.WordWrap
  }

  Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: root.recordsVisible

    Column {
      anchors.centerIn: parent
      width: parent.width
      spacing: dp(8)
      visible: recordsView.count === 0 && !root.errorMessage
      opacity: root.emptyOpacity

      StyledText {
        width: parent.width
        text: root.emptyTitle
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: root.emptyDescription ? Font.DemiBold : Font.Normal
        color: root.emptyDescription ? Theme.listItem.textColor : Theme.listItem.detailTextColor
      }
      StyledText {
        width: parent.width
        visible: root.emptyDescription.length > 0
        text: root.emptyDescription
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.listItem.detailTextColor
        font.pixelSize: sp(14)
      }
    }

    ListView {
      id: recordsView
      anchors.fill: parent
      clip: true
      spacing: dp(12)
      model: root.records
      delegate: Item {
        id: recordItem
        width: recordsView.width
        height: recordContent.implicitHeight + dp(32)
        // Stagger the first visible cards without delaying long lists.
        readonly property real cardProgress: root.entranceAnimation ? root.entranceAnimation.progressForCard(index + 2) : 1

        Rectangle {
          anchors.fill: parent
          radius: dp(16)
          color: recordMouse.pressed ? Theme.listItem.selectedBackgroundColor
                                    : Theme.listItem.backgroundColor
          border.color: Theme.listItem.dividerColor
          border.width: px(1)
          opacity: recordItem.cardProgress
          transform: Translate { y: (1 - recordItem.cardProgress) * dp(64) }

          MouseArea {
            id: recordMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: root.editable
            onClicked: root.recordClicked(modelData)
          }

          ColumnLayout {
            id: recordContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: dp(16)
            spacing: dp(10)

            RowLayout {
              Layout.fillWidth: true
              spacing: dp(12)
              StyledText {
                Layout.fillWidth: true
                text: modelData.date
                color: Theme.listItem.textColor
                font.pixelSize: sp(15)
                font.weight: Font.Medium
                elide: Text.ElideRight
              }
              StyledText {
                Layout.maximumWidth: recordContent.width * 0.5
                text: modelData.totalCost + " €"
                color: Theme.listItem.textColor
                horizontalAlignment: Text.AlignRight
                font.pixelSize: sp(20)
                font.weight: Font.DemiBold
                elide: Text.ElideLeft
              }
            }
            StyledText {
              Layout.fillWidth: true
              text: qsTr("%1 km · %2 L").arg(modelData.mileage).arg(modelData.liters)
              font.pixelSize: sp(14)
              color: Theme.listItem.detailTextColor
              wrapMode: Text.WordWrap
            }
          }
        }
      }
    }
  }
}
