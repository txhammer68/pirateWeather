import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

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

    RowLayout {
        id: simpleLayout
        anchors.fill: compactRep
        spacing: 0

        Text {
            text: isConfigured ? weatherAlert ? "⚠️":iconCode[weatherData.currently.panelIcon]:"?"
            color: Kirigami.Theme.textColor
            //verticalAlignment: Text.AlignVCenter
            font.pointSize: 14
            font.family: 'weathericons'
            Layout.alignment: Qt.AlignVCenter
        }
        Text {
            text: isConfigured ? weatherData.currently.temp:"--"
            color: Kirigami.Theme.textColor
            //verticalAlignment: Text.AlignVCenter
            font.pointSize: 13 //Theme.defaultFont.pointSize // Theme.fontSizeMedium// Theme.fontSizeSmall
            //fontSizeMode:  layoutType === 2 ? Text.FixedSize : Text.HorizontalFit
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 4
        }
    }
}
