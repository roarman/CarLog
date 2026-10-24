import QtQuick

NumberAnimation {
  id: animation
  property real progress: 0
  target: animation
  property: "progress"
  from: 0
  to: 1
  duration: 850
  easing.type: Easing.Linear

  // Stagger cards while keeping the entrance short for long lists.
  function progressForCard(index) {
    const cardTime = Math.max(0, Math.min(1, (progress - Math.min(index, 5) * 0.08) / 0.6))
    // Apply the easing per card so every card has the same movement duration.
    return 1 - Math.pow(1 - cardTime, 3)
  }
}
