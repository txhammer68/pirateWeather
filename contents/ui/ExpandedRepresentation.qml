import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core  as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
//import org.kde.kcoreaddons as KCoreAddons
import Qt5Compat.GraphicalEffects


Item {
    id: expandedRepresentation

    Layout.minimumWidth: Layout.minimumHeight * 1.5
    Layout.minimumHeight: PlasmaCore.Units.gridUnit * 7
    Layout.preferredWidth: Layout.preferredHeight * 1.5
    Layout.preferredHeight: PlasmaCore.Units.gridUnit * 22

    //readonly property bool verticalView: width / height < 1.8

    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (plasmoid.expanded) {
                root.retrievePosition();
            }
        }
    }

     Text {
        id:lastUpdate
        text:"Last update: "+ wData.last_update
        color:"gray"
        antialiasing : true
        font.pointSize:10
        anchors.top:expandedRepresentation.top
        anchors.right:expandedRepresentation.right


        MouseArea {
            id: updatemouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled:true
            onEntered: lastUpdate.color=Theme.viewHoverColor
            onExited:lastUpdate.color=Theme.viewTextColor
            onClicked: {
                wData.getWeather(wData.url2)
                wData.radarImage="";
                wData.radarImage="https://cdns.abclocal.go.com/three/ktrk/weather/16_9/SETX1_1280.jpg";
                wData.updateWeatherTimer.restart()
            }
        }
    }
    Row {
        id:conditions
        anchors.top:expandedRepresentation.top
        anchors.left:expandedRepresentation.left
        spacing:10

        Image {
            id:iconCode
            source:"../icons/"+wData.weather.currently.icon+".png"
            width:64
            height:64
            smooth:true
            anchors.topMargin:10
            anchors.top:conditions.top
        }

        Text {
            id:temp
            anchors.top:iconCode.top
            anchors.topMargin:10
            text:"  "+Math.round(wData.weather.currently.temperature)+"° "
            color:Theme.viewTextColor
            font.pointSize:24
            antialiasing : true
        }

        Text {
            id:summary
            anchors.bottom:temp.bottom
            text:wData.warnings ? wData.alert_text : wData.weather.currently.summary
            // if wData.weather alert show that instead of summary
            color:Theme.viewTextColor
            font.pointSize:16
            antialiasing : true

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: wData.warnings ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: wData.warnings ? true : false
                onEntered:wData.warnings ? summary.color=Theme.viewHoverColor: summary.color=Theme.viewTextColor
                onExited:wData.warnings ? summary.color=Theme.viewTextColor : summary.color=Theme.viewTextColor
                onClicked: {
                    Qt.openUrlExternally(wData.weather.alerts[0].uri)
                }
            }
        }
    }

    Text {
        id:story
        anchors.top:conditions.bottom
        anchors.left:conditions.left
        anchors.leftMargin:70
        anchors.topMargin:10
        text:wData.weather.hourly.summary+"<br> Real Feel: "+ Math.round(wData.weather.currently.apparentTemperature)+"° "+ " Humidity: "+Math.round((wData.weather.currently.humidity)*100)+"% "+" Wind: "+wData.degToCompass(wData.weather.currently.windBearing)+" at "+Math.round(wData.weather.currently.windSpeed)+"mph"//+" Gusts at "+Math.round(wData.weather.currently.windGust)+" mph"
        wrapMode:Text.WordWrap
        textFormat: Text.RichText
        Layout.fillWidth : true
        width:405
        color:Theme.viewTextColor
        font.pointSize:story.text.length > 110 ? 12 : 13.6
        antialiasing : true
    }

    Rectangle {
        id:ts
        anchors.top:story.bottom
        anchors.topMargin:10
        implicitWidth: expandedRepresentation.width*.95
        anchors.horizontalCenter:expandedRepresentation.horizontalCenter
        implicitHeight: 1
        radius:8
        color: "gray"
        antialiasing : true
        Layout.fillWidth: false
    }

    Row {
        id:forecast
        anchors.top:ts.bottom
        anchors.horizontalCenter:ts.horizontalCenter
        topPadding:10
        spacing:50
        Repeater {
            id:r1
            model: 5
            Text {
                text:Qt.formatDate(new Date(wData.weather.daily.data[index].time*1000)," ddd ")
                color:Theme.viewTextColor
                font.pointSize:14
                font.bold:true
                antialiasing : true

                Image {
                    source:"../icons/"+wData.weather.daily.data[index].icon+".png"
                    width:48
                    height:48
                    smooth:true
                    anchors.top:parent.bottom
                    anchors.horizontalCenter:parent.horizontalCenter

                    Text {
                        text:Math.round(wData.weather.daily.data[index].precipProbability*100/10)*10+"% "
                        color:Theme.viewTextColor
                        anchors.horizontalCenter:parent.horizontalCenter
                        anchors.top:parent.bottom
                        font.pointSize:12
                        antialiasing : true

                        Text {
                            text:Math.round(wData.weather.daily.data[index].temperatureLow)+"° | "+Math.round(wData.weather.daily.data[index].temperatureHigh)+"°"
                            color:Theme.viewTextColor
                            anchors.horizontalCenter:parent.horizontalCenter
                            anchors.top:parent.bottom
                            font.pointSize:12
                            antialiasing : true
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id:ts1
        anchors.top:forecast.bottom
        implicitWidth: expandedRepresentation.width*.95
        anchors.horizontalCenter:expandedRepresentation.horizontalCenter
        anchors.topMargin:105
        radius:8
        implicitHeight: 1
        color: "gray"
        antialiasing : true
        Layout.fillWidth: true
    }

    Column {
        id:radar_info
        anchors.top:ts1.bottom
        anchors.topMargin:10
        anchors.left:expandedRepresentation.left
        spacing:2

        Image {
            id:radar
            source:wData.radarImage
            smooth: false // allow opacity mask == false
            width: expandedRepresentation.width
            fillMode:Image.PreserveAspectFit
            visible: false
        }

        MouseArea {
            anchors.fill: radar
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            hoverEnabled: true
            cursorShape:Qt.PointingHandCursor
            onClicked: {
                Qt.openUrlExternally("https://abc13.com/weather/")
            }
        }

        OpacityMask {
            anchors.fill: radar
            source: radar
            maskSource: Rectangle {    // whats behind mask is visible, adds rounded corners to radar image
                width: radar.width
                height: radar.height
                radius: 8
                antialiasing : true
                visible: false // this also needs to be invisible or it will cover up the image
            }
        }
    }

    }

