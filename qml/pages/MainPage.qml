import QtQuick
import Felgo

AppPage {
  // view
  Navigation {
    id: navigation
    navigationMode: navigationModeTabs

    NavigationItem {
      id: homePageItem
      title: qsTr("Home")
      iconType: IconType.home

      NavigationStack {
        initialPage: HomePage { }
      }
    }
  }
}
