import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.configuration
import org.kde.kirigami.platform

Item {
    id: settingsPage
    property alias cfg_apiKey: apiNum.text
    //property alias cfg_interval:intervalSel.value

    signal configurationChanged

    Column {
        id:settingsInputs
        anchors.top:parent.top
        anchors.left:parent.left
        topPadding:5
        leftPadding:20
        width:parent.width-50
        spacing:10

        Image {
            id:logo
            source:"./logo.jpg"
        }

        Text {
            text:"Settings for Pirate Weather"
            color:Theme.textColor
            font.pointSize:16
        }

        Text {
            text:"Signup Here"
            color:Theme.textColor
            font.pointSize:14
            topPadding:5
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:Qt.PointingHandCursor
                onEntered: parent.color=Theme.hoverColor
                onExited: parent.color=Theme.textColor
                onClicked: Qt.openUrlExternally("https://pirate-weather.apiable.io/")
            }
        }

        Row {
            spacing:10
            Text {
                text:"Enter API Key"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.TextField {
                id: apiNum
                placeholderText: "Enter API Key"
                placeholderTextColor:Theme.disabledTextColor
                onAccepted: configurationChanged () //Plasmoid.configuration.writeConfig()
                onTextChanged:configurationChanged  ()
            }
        }
    }
}
