import QtQuick
import Felgo

AppPage {
  title: qsTr("Home")

  AppText {
    anchors.centerIn: parent
    text: dataModel.carName
  }
}
