import Felgo
import QtQuick
import "model"
import "logic"
import "pages"
import "components"


App {
  color: Theme.colors.backgroundColor

  // Open the first page only after Felgo's launch screen has faded out.
  onSplashScreenFinished: {
    appNavigation.push(onboardingPage)
    if (dataModel.onboardingCompleted)
      appNavigation.push(mainPageComponent)
  }

  onInitTheme: {
    Theme.colors.statusBarStyle = Theme.colors.statusBarStyleWhite

    // Colors customization
    Theme.colors.backgroundColor = "#f7f4f2"
    Theme.colors.secondaryBackgroundColor = Theme.colors.backgroundColor
    Theme.colors.tintColor = "#b83232"
    Theme.colors.secondaryTextColor = "#030303"
    Theme.colors.textColor = "black"

    // Shared card colors for Home and Statistics.
    Theme.listItem.backgroundColor = "#ffffff"
    Theme.listItem.dividerColor = "#eae2df"
    Theme.listItem.textColor = "#292426"
    Theme.listItem.detailTextColor = "#786d6d"
    Theme.listItem.selectedBackgroundColor = "#f0e9e7"
    Theme.listItem.activeBackgroundColor = "#f8e9e7"

    Theme.appButton.backgroundColorPressed = "#962828"
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

    onTransitioningChanged: {
      if (!transitioning && dataModel.onboardingCompleted)
        onboardingPage.revealMainPage()
    }
  }

  OnboardingPage {
    id: onboardingPage
    visible: false
    // The retained onboarding page must not flash behind Main on a saved launch.
    opacity: dataModel.onboardingCompleted ? 0 : 1
    transitionOverlay: appTransitionOverlay
    onOnboardingFinished: function(carName) {
      logic.onboardingFinished(carName)
      if (dataModel.onboardingCompleted && !appNavigation.transitioning)
        onboardingPage.revealMainPage()
    }
  }

  Component {
    id: mainPageComponent
    MainPage {}
  }

  Component {
    id: fuelRecordComponent
    AddFuelRecordPage {
      onSaved: appNavigation.pop()
      onDeleted: appNavigation.pop()
    }
  }

  Connections {
    target: appNavigation.currentPage
    ignoreUnknownSignals: true

    function onAddFuelRecordRequested() {
      appNavigation.push(fuelRecordComponent)
    }

    function onEditFuelRecordRequested(record) {
      appNavigation.push(fuelRecordComponent, {recordToEdit: record})
    }
  }

  Connections {
    target: dataModel

    function onOnboardingCompletedChanged() {
      if (!dataModel.onboardingCompleted)
        onboardingPage.resetForm()

      if (appNavigation.depth > 0) {
        if (dataModel.onboardingCompleted)
          appNavigation.push(mainPageComponent)
        else
          appNavigation.popAllExceptFirst()
      }
    }
  }

  TransitionOverlay {
    id: appTransitionOverlay
    anchors.fill: parent
  }

}
