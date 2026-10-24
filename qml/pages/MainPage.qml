import QtQuick
import Felgo

AppPage {
  id: root
  title: navigation.currentIndex === 0 ? qsTr("Home") : qsTr("Statistics")
  backNavigationEnabled: false
  signal addFuelRecordRequested()
  signal editFuelRecordRequested(var record)

  // Wait for both the page transition and circular reveal before animating cards.
  readonly property bool isEntranceReady: isCurrentStackPage && navigationStack
                                       && !navigationStack.transitioning
                                       && !appTransitionOverlay.running

  function playCurrentEntrance() {
    if (!isEntranceReady)
      return
    const item = navigation.currentIndex === 0 ? homePageItem : statisticsPageItem
    if (item.page)
      item.page.playEntrance()
  }

  onIsEntranceReadyChanged: {
    // Let Home receive the updated readiness binding before starting its animation.
    if (isEntranceReady)
      Qt.callLater(playCurrentEntrance)
  }

  Navigation {
    id: navigation
    navigationMode: navigationModeTabs
    // Lazy tab content may not be connected until the selection handler finishes.
    onCurrentIndexChanged: Qt.callLater(root.playCurrentEntrance)

    NavigationItem {
      id: homePageItem
      title: qsTr("Home")
      iconType: IconType.home

      HomePage {
        useSafeArea: false
        isEntranceReady: root.isEntranceReady
        onAddFuelRecordRequested: root.addFuelRecordRequested()
        onEditFuelRecordRequested: function(record) {
          root.editFuelRecordRequested(record)
        }
      }
    }

    NavigationItem {
      id: statisticsPageItem
      title: qsTr("Statistics")
      iconType: IconType.barchart

      StatisticsPage { useSafeArea: false }
    }
  }
}
