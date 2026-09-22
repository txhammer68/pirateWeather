import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid

Item {
    id: fullRepresentation
    Layout.preferredWidth:570
    Layout.preferredHeight:410
    Layout.minimumWidth:500
    Layout.maximumWidth:600
    Layout.minimumHeight:220
    Layout.maximumHeight:460

    Connections { // reset forecast views after popup closed
        target: root
        function onExpandedChanged() {
            viewLoad.item.hourlyForecastAlias.positionViewAtBeginning()
            viewLoad.item.dailyForecastAlias.visible=false
            viewLoad.item.hourlyForecastAlias.visible=true
        }

        function onShowForecastChanged () {
            if(showForecast) {
                Layout.preferredHeight=420
            }
            else {
                Layout.preferredHeight=300
            }
         }
    }


    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Button {
        text: "Configure Weather"
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.verticalCenter:parent.verticalCenter
        visible: Plasmoid.configurationRequired // Only shows if the config is missing
        onClicked: {
            // Triggers the system's native configure action manually
            plasmoid.internalAction("configure").trigger()
        }
    }

    Loader {
        id:viewLoad
        sourceComponent: !Plasmoid.configurationRequired ? fullRep:undefined
        active:true
        onLoaded: {
            if (Plasmoid.configurationRequired == false) {
                anchors.fill=fullRepresentation
            }
        }
    }

    Component {
        id: fullRep

        Item {
            property alias hourlyForecastAlias:hourlyForecast
            property alias dailyForecastAlias:dailyForecast

            ToolTip {
                id: wtips
                text: weatherData.currently.warnings ?  weatherData.currently.weatherAlertsDesc : ""
                visible: false
                delay:1000
                x:story.x+80
                y:story.y+120
                contentItem: Text {
                    text: wtips.text
                    font.pointSize:12
                    width:320
                    leftPadding:10
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    color: textColor
                    antialiasing:true
                }
                background: Rectangle {
                    color:activeBackgroundColor
                    radius:6
                    width:parent.width+20
                    antialiasing:true
                }
            }

            Text {
                text: weatherData.currently.lastUpdate
                color:disabledTextColor
                antialiasing : true
                font.pointSize:10
                anchors.top:parent.top
                anchors.right:parent.right
                anchors.margins:5

                MouseArea {
                    id: updatemouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled:true
                    onEntered: parent.color=linkColor
                    onExited:parent.color=textColor
                    onClicked:getData(weatherURL)
                }
            }

            Text {
                id:location
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.topMargin:5
                anchors.leftMargin:10
                text: isConfigured ? cityName.length > 0 ? cityName + "," + regionName : "":"--"
                color:textColor
                font.pointSize:11
                antialiasing : true
            }

            Row {
                id:conditions
                anchors.top:location.bottom
                anchors.left:parent.left
                anchors.topMargin:5
                anchors.leftMargin:10
                spacing:10

                Image {
                    id:iconCode
                    source:weatherData.currently.icon
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
                    text:weatherData.currently.temperature
                    color:textColor
                    font.pointSize:20
                    antialiasing : true
                }

                Text {
                    id:summary
                    anchors.bottom:temp.bottom
                    text:weatherData.currently.conditions
                    color:textColor
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
                width: parent.width*.95
                spacing:10

                Text {
                    id:story
                    text:weatherData.currently.warnings ? weatherData.currently.alertText : weatherData.currently.summary
                    Layout.fillWidth : true
                    wrapMode:Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    width:parent.width*.95
                    color:textColor
                    font.pointSize:14
                    antialiasing : true

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: weatherData.currently.warnings ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: weatherData.currently.warnings ? true : false
                        onEntered:{
                            if (weatherData.currently.warnings) {
                                parent.color=linkColor
                                wtips.visible=true
                            }
                            else {
                                parent.color=textColor
                            }
                        }
                        onExited:{
                            if (weatherData.currently.warnings) {
                                parent.color=textColor
                                wtips.visible=false
                            }
                            else {
                                parent.color=textColor
                            }
                        }
                        onClicked: {
                            Qt.openUrlExternally(weatherData.currently.weatherAlertsURL)
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
                            text:"Feels Like"
                            color:textColor
                            font.pointSize:11
                            antialiasing : true
                            width:79
                        }
                        Text {
                            text:"Humidity"
                            color:textColor
                            font.pointSize:11
                            antialiasing : true
                            width:76
                        }
                        Text {
                            text:"Winds"
                            color:textColor
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
                            color:textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.apparentTemperature
                            color:textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }

                        Text {
                            text:"\uf07a"
                            color:textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }

                        Text {
                            text:weatherData.currently.humidity
                            color:textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }

                        Text {
                            text:"\uf050"
                            color:textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:10
                            bottomPadding:5
                        }
                        Text {
                            text:weatherData.currently.windGust > 0 && weatherData.currently.windGust > weatherData.currently.windSpeed ? weatherData.currently.windBearing+" at "+weatherData.currently.windSpeed + " to "+weatherData.currently.windGust +" "+ windUnits : weatherData.currently.windBearing+" at "+weatherData.currently.windSpeed+" "+windUnits
                            color:textColor
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
                            color:textColor
                            font.pointSize:11
                            antialiasing : true
                            width:79
                        }
                        Text {
                            text:"Visibility"
                            color:textColor
                            font.pointSize:11
                            antialiasing : true
                            width:76
                        }
                        Text {
                            text:"AQI"
                            color:textColor
                            font.pointSize:11
                            antialiasing : true
                            width:106
                        }
                        Text {
                            text:"UVI"
                            color:textColor
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
                            color:textColor
                            font.pointSize:14
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.dewPoint
                            color:textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }
                        Text {
                            text:"\uf047"
                            color:textColor
                            font.pointSize:14
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.visibility + (units=="us" ? "mi":"km")
                            color:textColor
                            font.pointSize:14
                            antialiasing : true
                            topPadding:2
                            width:48
                        }
                        Text {
                            text:"\uf063"
                            color:textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:calcAQI()
                            color:textColor
                            font.pointSize:14
                            antialiasing : true
                            width:72
                        }
                        Text {
                            text:"\uf00d"
                            color:textColor
                            font.pointSize:11
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                            topPadding:2
                        }
                        Text {
                            text:calcUVI()
                            color:textColor
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
                width: parent.width*.95
                anchors.horizontalCenter:parent.horizontalCenter
                height: 1
                color: disabledTextColor
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
                    border.color:hourlyForecast.visible ? linkColor : disabledTextColor
                    radius:6
                    antialiasing:true

                    Text {
                        text:"Hourly"
                        color:hourlyForecast.visible ? textColor : disabledTextColor
                        anchors.centerIn:parent
                        antialiasing:true
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
                    border.color:dailyForecast.visible ? linkColor : disabledTextColor
                    radius:6
                    antialiasing:true

                    Text {
                        text:"Daily"
                        color:dailyForecast.visible ? textColor : disabledTextColor
                        anchors.centerIn:parent
                        antialiasing:true
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
                    spacing:7
                    Layout.alignment:Qt.AlignHCenter

                    Text {
                        id:timeofDay
                        text:weatherData.hourly[index].time
                        color:textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:10
                        antialiasing : true
                        font.bold:true
                    }

                    Image {
                        source:weatherData.hourly[index].icon
                        width:38
                        height:38
                        Layout.alignment:Qt.AlignHCenter
                        sourceSize.height:height
                        sourceSize.width:width
                        smooth:true
                    }

                    Text {
                        text:weatherData.hourly[index].precip
                        color:textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing : true
                    }

                    Text {
                        text:weatherData.hourly[index].temp
                        color:textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing : true
                    }
                }
            }

            Component{
                id:dailyList

                ColumnLayout {
                    spacing:7
                    Layout.alignment:Qt.AlignHCenter

                    Text {
                        text:weatherData.daily[index].time
                        color:textColor
                        font.pointSize:12
                        font.bold:true
                        Layout.alignment:Qt.AlignHCenter
                        antialiasing:true
                    }

                    Image {
                        source:weatherData.daily[index].icon
                        width:36
                        height:36
                        sourceSize.height:height
                        sourceSize.width:width
                        smooth:true
                        Layout.alignment:Qt.AlignHCenter
                    }

                    Text {
                        text:weatherData.daily[index].precip
                        color:textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing:true
                    }

                    Text {
                        text:weatherData.daily[index].lowTemp+" | "+weatherData.daily[index].highTemp
                        color:textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing:true
                    }
                }
            }

            Item {
                id:hourly
                anchors.top:viewForecast.bottom
                anchors.topMargin:15
                anchors.left:parent.left
                anchors.leftMargin:15
                width:parent.width*.96
                height:128
                visible:showForecast
                ListView {
                    id:hourlyForecast
                    anchors.top:hourly.top
                    anchors.left:hourly.left
                    visible:true
                    spacing:14
                    width:hourly.width
                    contentWidth: hourly.width
                    height:128
                    orientation:ListView.Horizontal
                    layoutDirection:Qt.LeftToRight
                    snapMode: ListView.SnapToItem
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration:500
                    clip:true
                    interactive:true
                    model:weatherData.hourly
                    onModelChanged:{
                        hourlyForecast.positionViewAtBeginning()
                        dailyForecast.visible=false
                        hourlyForecast.visible=true
                    }
                    delegate:hourlyList
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled:false
                        propagateComposedEvents: false
                        acceptedButtons: Qt.NoButton
                        onWheel: (event) => {
                            if (event.angleDelta.y > 0) {
                                // Scroll up -> Decrease index by 4 (stop at 0)
                                hourlyForecast.currentIndex = Math.max(0, hourlyForecast.currentIndex - 4);
                            } else if (event.angleDelta.y < 0) {
                                // Scroll down -> Increase index by 4 (stop at the last item)
                                hourlyForecast.currentIndex = Math.min(hourlyForecast.count - 1, hourlyForecast.currentIndex + 4);
                            }
                            event.accepted = true;
                        }
                    }
                }
            }

            Item {
                id:daily
                anchors.top:viewForecast.bottom
                anchors.left:parent.left
                anchors.topMargin:15
                anchors.leftMargin:15
                width:parent.width*.98
                height:128
                visible:showForecast

                ListView {
                    id:dailyForecast
                    anchors.top:daily.top
                    anchors.left:daily.left
                    visible:false
                    spacing:18
                    width:daily.width
                    contentWidth: daily.width
                    height:128
                    orientation:ListView.Horizontal
                    layoutDirection:Qt.LeftToRight
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    clip:true
                    interactive:false
                    model:7//weatherData.daily.data
                    delegate:dailyList
                }
            }
        }
    }
}
