import QtQuick
import QtQuick.Shapes
import Felgo

Item {
  id: root

  property color fillColor: Theme.colors.tintColor
  property int startDelay: 180
  property int coverDuration: 500
  property int revealDuration: 500
  readonly property bool running: coverAnimation.running
                                  || revealAnimation.running
                                  || transitionState.waitingForReveal

  signal covered()
  signal finished()

  z: 1000
  visible: running
  clip: true

  function start() {
    if (running)
      return

    transitionState.revealing = false
    transitionState.revealProgress = 0
    circle.scale = 0
    coverAnimation.start()
  }

  function reveal() {
    if (!transitionState.waitingForReveal)
      return

    transitionState.revealing = true
    revealAnimation.start()
    transitionState.waitingForReveal = false
  }

  QtObject {
    id: transitionState
    property bool waitingForReveal: false
    property bool revealing: false
    property real revealProgress: 0
    readonly property real diagLength: Math.sqrt(root.width * root.width + root.height * root.height) / 2
    readonly property real revealRadius: revealProgress * diagLength
  }

  Rectangle {
    id: circle
    anchors.centerIn: parent
    width: transitionState.diagLength * 2
    height: width
    radius: width / 2
    scale: 0
    color: root.fillColor
    antialiasing: true
    visible: !transitionState.revealing
  }

  Shape {
    anchors.fill: parent
    visible: transitionState.revealing
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: root.fillColor
      strokeWidth: -1
      fillRule: ShapePath.OddEvenFill
      startX: 0
      startY: 0

      PathLine { x: root.width; y: 0 }
      PathLine { x: root.width; y: root.height }
      PathLine { x: 0; y: root.height }
      PathLine { x: 0; y: 0 }

      // The second path cuts a growing circular opening out of the cover.
      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: transitionState.revealRadius
        radiusY: transitionState.revealRadius
        startAngle: 0
        sweepAngle: 360
        moveToStart: true
      }
    }
  }

  // Block interaction
  MouseArea {
    anchors.fill: parent
  }

  SequentialAnimation {
    id: coverAnimation

    PauseAnimation { duration: root.startDelay }

    NumberAnimation {
      target: circle
      property: "scale"
      from: 0
      to: 2
      duration: root.coverDuration
      easing.type: Easing.InOutCubic
    }

    onFinished: {
      transitionState.waitingForReveal = true
      root.covered()
    }
  }

  NumberAnimation {
    id: revealAnimation
    target: transitionState
    property: "revealProgress"
    from: 0
    to: 1
    duration: root.revealDuration
    easing.type: Easing.InOutCubic
    onFinished: root.finished()
  }
}
