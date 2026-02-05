import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami.platform

Item {
    id: compactRep

    MouseArea {
        id: mouseArea
        anchors.fill: compactRep
        onClicked: {
            weatherAlert=false
            root.expanded = !root.expanded
        }
    }

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    RowLayout {
        id: simpleLayout
        anchors.fill: parent
        spacing: 0

        Text {
            text: isConfigured ? weatherAlert ? "⚠️":iconCode[weatherData.currently.icon]:"?"
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 14
            font.family: 'weathericons'
            Layout.alignment: Qt.AlignVCenter
        }
        Text {
            text: isConfigured ? Math.round(weatherData.currently.temperature)+"° " : "--"
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 13 //Theme.defaultFont.pointSize // Theme.fontSizeMedium// Theme.fontSizeSmall
            //fontSizeMode:  layoutType === 2 ? Text.FixedSize : Text.HorizontalFit
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 4
        }
    }
}
