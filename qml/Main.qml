import Felgo
import QtQuick
import "model"
import "logic"
import "pages"


App {
  color: "white"

  onInitTheme: {
    Theme.colors.statusBarStyle = Theme.colors.statusBarStyleWhite

    // Colors customization
    Theme.colors.backgroundColor = "#fff"
    Theme.colors.secondaryBackgroundColor = Theme.colors.backgroundColor
    Theme.colors.tintColor = "#b83232"
    Theme.colors.secondaryTextColor = "#030303"
    Theme.colors.textColor = "black"
  }

  Storage {
    id: storage
  }

  Logic {
    id: logic
  }

  DataModel {
    id: dataModel
    dispatcher: logic // data model handles actions sent by logic
  }

  Loader {
    anchors.fill: parent
    source: dataModel.onboardingCompleted
            ? "pages/MainPage.qml"
            : "pages/OnboardingPage.qml"
  }
}
