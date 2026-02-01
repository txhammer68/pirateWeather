import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components
import org.kde.plasma.core
import org.kde.plasma.plasmoid

Item {
    id: compactItem

    anchors.fill: parent

    property bool inTray
    property int layoutType: inTray ? 2 : main.layoutType

    property double parentWidth: parent.width
    property double parentHeight: parent.height

    property double partHeight: 0

    property double widgetWidth: 0
    property double widgetHeight: 0

    property int boxLeft: 0
    property int boxTop: 0
    property int boxWidth: 0
    property int boxHeight: 0

    onParentWidthChanged: {
        computeWidgetSize()
    }

    onParentHeightChanged: {
        computeWidgetSize()
    }

    onLayoutTypeChanged: {
        computeWidgetSize()
    }

    function computeWidgetSize() {
      widgetWidth = compactItem.width
      widgetHeight = compactItem.height

      if ((widgetWidth === 0) || (widgetHeight === 0))
        return

      switch (layoutType) {
        case 0:
          boxWidth = widgetHeight
          boxHeight = widgetHeight
          widgetWidth = widgetHeight * 2
          break
        case 1:
          boxWidth = widgetHeight
          boxHeight = widgetHeight / 2
          widgetWidth = widgetHeight
          break
        case 2:
          boxWidth = widgetHeight
          boxHeight = widgetHeight
          widgetWidth = widgetHeight
          break
      }
      compactRepresentation.Layout.preferredHeight = widgetHeight
      compactRepresentation.Layout.preferredWidth = widgetWidth
    }

    property double fontPixelSize: boxHeight * (layoutType === 2 ? 0.6 : 0.65)

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    Item {
        id: innerWindow
        anchors.fill: parent

        Label {
            width: boxWidth
            height: boxHeight

            anchors.left: parent.left
            anchors.leftMargin: layoutType === 0 ? boxWidth*.8 : 0
            anchors.top: parent.top
            anchors.topMargin: layoutType === 1 ? boxHeight : 0

            horizontalAlignment: layoutType === 2 ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode:  layoutType === 2 ? Text.FixedSize : Text.HorizontalFit
            font.family: 'weathericons'
            text: wData.iconCode[wData.weatherData.currently.icon]

            opacity: 1

            font.pixelSize: fontPixelSize * (layoutType === 2 ? 0.6 : .9)
            font.pointSize: -1
        }
      Label {
            id: temperatureText

            width: boxWidth
            height: boxHeight

              anchors.left: parent.left
              anchors.leftMargin: 0
              anchors.top: parent.top
              anchors.topMargin: 0

            horizontalAlignment: layoutType === 1 ? Text.AlignHCenter : Text.AlignRight
            verticalAlignment: layoutType === 2 ? Text.AlignBottom : Text.AlignVCenter

            text: Math.round(wData.weatherData.currently.temperature)+"° "
            fontSizeMode:  layoutType === 2 ? Text.Fit : Text.HorizontalFit
            font.pixelSize: fontPixelSize * (layoutType === 2 ? 0.6 : .8)
            font.pointSize: -1
        }
    }
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      onClicked: root.expanded = !root.expanded
    }
}
