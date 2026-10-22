import Felgo
import QtQuick
import "model"
import "logic"
import "pages"
import "components"


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

  NavigationStack {
    id: appNavigation
    anchors.fill: parent
    splitView: false

    Component.onCompleted: {
      push(dataModel.onboardingCompleted ? mainPageComponent : onboardingPage)
    }

    onTransitionFinished: {
      if (dataModel.onboardingCompleted)
        onboardingPage.revealMainPage()
    }
  }

  OnboardingPage {
    id: onboardingPage
    visible: false
    navigationBarHidden: true
    transitionOverlay: appTransitionOverlay
    onOnboardingFinished: function(carName) {
      logic.onboardingFinished(carName)
      Qt.callLater(function() {
        if (dataModel.onboardingCompleted && !appNavigation.transitioning)
          onboardingPage.revealMainPage()
      })
    }
  }

  Component {
    id: mainPageComponent
    MainPage { navigationBarHidden: true }
  }

  Connections {
    target: dataModel

    function onOnboardingCompletedChanged() {
      if (!dataModel.onboardingCompleted)
        onboardingPage.resetForm()

      if (appNavigation.depth > 0) {
        appNavigation.clearAndPush(dataModel.onboardingCompleted
                                   ? mainPageComponent : onboardingPage)
      }
    }
  }

  TransitionOverlay {
    id: appTransitionOverlay
    anchors.fill: parent
  }

}
