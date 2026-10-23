import QtQuick
import Felgo

AppPage {
  id: root
  // view
  Navigation {
    id: navigation
    navigationMode: navigationModeTabs

    NavigationItem {
      id: homePageItem
      title: qsTr("Home")
      iconType: IconType.home

      NavigationStack {
        id: homeNavigation
        initialPage: HomePage {
          onAddFuelRecordRequested: homeNavigation.push(addFuelRecordComponent)
          onEditFuelRecordRequested: function(record) {
            homeNavigation.push(addFuelRecordComponent, {recordToEdit: record})
          }
        }

        Component {
          id: addFuelRecordComponent
          AddFuelRecordPage {
            onSaved: homeNavigation.pop()
            onDeleted: homeNavigation.pop()
          }
        }
      }
    }
  }
}
