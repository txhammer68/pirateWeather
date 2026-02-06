import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami.platform

Item {
    id: fullRepresentation
    Layout.preferredWidth: 540
    Layout.preferredHeight: showForecast ? 320:260
    width: 540
    height: showForecast ? 320:260

    Connections {
        target: root
        function onExpandedChanged() {
            hourlyForecast.positionViewAtBeginning()
            hourlyForecast.visible=true
            dailyForecast.visible=false
        }
    }

    Text {
        text:isConfigured ? lastUpdate : "NA"
        color:Theme.disabledTextColor
        antialiasing : true
        font.pointSize:10
        anchors.top:fullRepresentation.top
        anchors.right:fullRepresentation.right
        anchors.margins:5

        MouseArea {
            id: updatemouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled:true
            onEntered: parent.color=Theme.linkColor
            onExited:parent.color=Theme.textColor
            onClicked:getData(weatherURL)
        }
    }

    Text {
        id:location
        anchors.top:fullRepresentation.top
        anchors.left:fullRepresentation.left
        anchors.topMargin:5
        anchors.leftMargin:10
        text:isConfigured ? cityName.length > 0 ? cityName + "," + regionName : "":"--"
        color:Theme.textColor
        font.pointSize:11
        antialiasing : true
    }

    Row {
        id:conditions
        anchors.top:location.bottom
        anchors.left:fullRepresentation.left
        anchors.topMargin:5
        anchors.leftMargin:10
        spacing:10

        Image {
            id:iconCode
            source:isConfigured ? "../icons/"+weatherData.currently.icon+".svg" : "../icons/na.png"
            width:48
            height:48
            smooth:true
            anchors.topMargin:10
            anchors.top:conditions.top
        }

        Text {
            id:temp
            anchors.top:iconCode.top
            anchors.topMargin:10
            text:isConfigured ? "  "+Math.round(weatherData.currently.temperature)+"° " : "NA"
            color:Theme.textColor
            font.pointSize:20
            antialiasing : true
        }

        Text {
            id:summary
            anchors.bottom:temp.bottom
            text:isConfigured ? weatherData.currently.summary : "--"
            color:Theme.textColor
            font.pointSize:20
            antialiasing : true
        }
    }

    Column {
        id:currentConds
        anchors.top:conditions.bottom
        anchors.left:conditions.left
        anchors.leftMargin:5
        anchors.topMargin:15
        width: fullRepresentation.width*.95
        spacing:10

        Text {
            id:story
            text:isConfigured ?  weatherWarnings ? alertText : weatherData.hourly.summary : "No Data,Check Settings or Network Connection,Refresh Data"
            Layout.fillWidth : true
            fontSizeMode:Text.HorizontalFit
            minimumPixelSize: 9
            wrapMode:Text.NoWrap
            maximumLineCount: 1
            elide: Text.ElideRight
            width:fullRepresentation.width*.95
            color:Theme.textColor
            font.pointSize:12
            antialiasing : true
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: weatherWarnings ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: weatherWarnings ? true : false
                onEntered:weatherWarnings ? parent.color=Theme.linkColor : parent.color=Theme.textColor
                onExited:weatherWarnings ? parent.color=Theme.textColor : parent.color=Theme.textColor
                onClicked: {
                    Qt.openUrlExternally(weatherData.alerts[0].uri)
                }
            }
        }

        Item {
            width:parent.width
            height:15

            Row {
                spacing:25
                width:parent.width
                bottomPadding:5
                Text {
                    text:"Real Feel"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:76
                }
                Text {
                    text:"Humidity"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:74
                }
                Text {
                    text:"Winds"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:72
                }
            }

            Row {
                width:parent.width
                spacing:25
                topPadding:20
                Text {
                    text:"\uf055"
                    color:Theme.textColor
                    font.pointSize:12
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                }
                Text {
                    text:Math.round(weatherData.currently.apparentTemperature)+"°"
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:48
                }

                Text {
                    text:"\uf07a"
                    color:Theme.textColor
                    font.pointSize:12
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                }

                Text {
                    text:Math.round(weatherData.currently.humidity*100)+"%"
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:48
                }

                Text {
                    text:"\uf050"
                    color:Theme.textColor
                    font.pointSize:12
                    font.family: 'weathericons'
                    antialiasing : true
                    width:10
                    bottomPadding:5
                }
                Text {
                    text:weatherData.currently.windGust > 0 ? degToCompass(weatherData.currently.windBearing)+" at "+Math.round(weatherData.currently.windSpeed) + " to "+Math.round(weatherData.currently.windGust) + windUnits : degToCompass(weatherData.currently.windBearing)+" at "+Math.round(weatherData.currently.windSpeed)+ windUnits
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:48
                }
            }
        }

        Item {
            width:parent.width
            height:15

            Row {
                spacing:25
                width:parent.width
                bottomPadding:10
                topPadding:30

                Text {
                    text:"Dew Point"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:76
                }
                Text {
                    text:"Visibility"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:78
                }
                Text {
                    text:"AQI"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:80
                }
                Text {
                    text:"UVI"
                    color:Theme.textColor
                    font.pointSize:11
                    antialiasing : true
                    width:76
                }
            }

            Row {
                spacing:25
                topPadding:50
                width:parent.width
                Text {
                    text:"\uf04e"
                    color:Theme.textColor
                    font.pointSize:14
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                }
                Text {
                    text:Math.round(weatherData.currently.dewPoint)+"°"
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:48
                }
                Text {
                    text:"\uf047"
                    color:Theme.textColor
                    font.pointSize:14
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                }
                Text {
                    text:Math.round(weatherData.currently.visibility) + (units=="us" ? "mi":"km")
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    topPadding:2
                    width:48
                }
                Text {
                    text:"\uf063"
                    color:Theme.textColor
                    font.pointSize:12
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                }
                Text {
                    text:calcAQI()
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:72
                }
                Text {
                    text:"\uf00d"
                    color:Theme.textColor
                    font.pointSize:11
                    font.family: 'weathericons'
                    antialiasing : true
                    width:5
                    topPadding:2
                }
                Text {
                    text:calcUVI()
                    color:Theme.textColor
                    font.pointSize:14
                    antialiasing : true
                    width:48
                }
            }
        }
    }

    Rectangle {
        id:ts
        anchors.top:currentConds.bottom
        anchors.topMargin:65
        width: fullRepresentation.width*.95
        anchors.horizontalCenter:fullRepresentation.horizontalCenter
        height: 1
        color: Theme.disabledTextColor
        antialiasing : true
        visible:showForecast
    }

    Row {
        id:viewForecast
        spacing:10
        anchors.top:ts.bottom
        anchors.topMargin:10
        anchors.bottomMargin:10
        anchors.horizontalCenter:ts.horizontalCenter
        visible:showForecast

        Rectangle {
            id:hourlyBtn
            width:96
            height:32
            color:"transparent"
            border.color:hourlyForecast.visible ? Theme.linkColor : Theme.activeBackgroundColor
            radius:6

            Text {
                text:"Hourly"
                color:Theme.textColor
                anchors.centerIn:parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onClicked:{
                    hourlyForecast.visible=true
                    dailyForecast.visible=false
                }
            }
        }

        Rectangle {
            id:dailyBtn
            width:96
            height:32
            color:"transparent"
            border.color:dailyForecast.visible ? Theme.linkColor : Theme.activeBackgroundColor
            radius:6

            Text {
                text:"Daily"
                color:Theme.textColor
                anchors.centerIn:parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onClicked:{
                    hourlyForecast.visible=false
                    dailyForecast.visible=true
                }
            }
        }
    }

    Component{
        id:hourlyList

        ColumnLayout {
            spacing:10
            Layout.alignment:Qt.AlignHCenter

            Text {
                id:timeofDay
                text:Qt.formatTime(new Date(weatherData.hourly.data[index].time*1000))
                color:Theme.textColor
                font.pointSize:10
                antialiasing : true
                font.bold:true
                width:64
            }

            Image {
                source:"../icons/"+weatherData.hourly.data[index].icon+".svg"
                width:32
                height:32
                anchors.horizontalCenter:timeofDay.horizontalCenter
                sourceSize.height:height
                sourceSize.width:width
                smooth:true
                antialiasing:true
            }

            Text {
                text:Math.round(weatherData.hourly.data[index].temperature)+"°  ~  "+Math.floor(weatherData.hourly.data[index].precipProbability*100/10)*10+"%"
                color:Theme.textColor
                font.pointSize:10
                antialiasing : true
            }
        }
    }

    Item {
        id:hourly
        anchors.top:viewForecast.bottom
        anchors.topMargin:10
        anchors.left:fullRepresentation.left
        anchors.leftMargin:20
        width:fullRepresentation.width*.96
        height:128
        visible:showForecast
        ListView {
            id:hourlyForecast
            anchors.top:hourly.top
            anchors.left:hourly.left
            visible:true
            spacing:10
            width:hourly.width
            contentWidth: hourly.width
            height:128
            orientation:ListView.Horizontal
            layoutDirection:Qt.LeftToRight
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds
            clip:true
            interactive:false
            model:weatherData.hourly.data
            delegate:hourlyList
            ScrollBar.horizontal: ScrollBar {
                id:scroll
                //policy: ScrollBar.AsNeeded
                orientation: Qt.Horizontal
                stepSize:.125
                //size:.
                parent: hourlyForecast.parent
                hoverEnabled: true
                active: hovered || pressed
                interactive: false
                anchors.fill:hourlyForecast
                contentItem: Rectangle {
                    id:rect1
                    implicitWidth: 4
                    radius:6
                    color:Theme.textColor
                    antialiasing:true
                    smooth:true
                    opacity:scroll.active ? 1:0
                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 500
                            easing.type: opacity ? Easing.OutCubic:Easing.InCubic
                        }}
                }
                background: Rectangle {
                    id:rect2
                    implicitWidth: 4
                    radius:6
                    opacity:scroll.active  ? .65:0
                    color: "black"
                    antialiasing:true
                    smooth:true
                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 500
                            easing.type: opacity ? Easing.OutCubic:Easing.InCubic
                        }}
                }
                MouseArea {
                    anchors.fill: parent
                    onWheel: {
                        if (wheel.angleDelta.y > 0) scroll.decrease()
                            else scroll.increase()
                    }
                }
            }
        }
    }

    Item {
        id:daily
        anchors.top:viewForecast.bottom
        anchors.left:fullRepresentation.left
        anchors.topMargin:10
        anchors.leftMargin:30
        width:fullRepresentation.width
        height:128
        visible:showForecast

        RowLayout {
            id:dailyForecast
            spacing:10
            width:daily.width
            Layout.alignment:Qt.AlignHCenter
            visible:false
            Repeater {
                id:r1
                model: 6
                Text {
                    text:Qt.formatDate(new Date(weatherData.daily.data[index].time*1000)," ddd ")
                    color:Theme.textColor
                    font.pointSize:12
                    font.bold:true
                    antialiasing : true

                    Image {
                        source:"../icons/"+weatherData.daily.data[index].icon+".svg"
                        width:36
                        height:36
                        smooth:true
                        antialiasing : true
                        anchors.top:parent.bottom
                        anchors.horizontalCenter:parent.horizontalCenter

                        Text {
                            text:Math.round(weatherData.daily.data[index].precipProbability*100/10)*10+"% "
                            color:Theme.textColor
                            anchors.horizontalCenter:parent.horizontalCenter
                            anchors.top:parent.bottom
                            font.pointSize:12
                            antialiasing : true

                            Text {
                                text:Math.round(weatherData.daily.data[index].temperatureLow)+"° | "+Math.round(weatherData.daily.data[index].temperatureHigh)+"°"
                                color:Theme.textColor
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
    }
}
