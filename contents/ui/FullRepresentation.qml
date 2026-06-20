import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: fullRepresentation
    Layout.preferredWidth:570
    Layout.preferredHeight:420
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

    Loader {
        id:viewLoad
        sourceComponent: !Plasmoid.configurationRequired ? fullRep:configRepresentation
        active:true
        onLoaded: {
            if (Plasmoid.configurationRequired == false) {
                anchors.fill=fullRepresentation
            }
            else {
                anchors.horizontalCenter=parent.horizontalCenter
                anchors.verticalCenter=parent.verticalCenter
            }
        }
    }

    Component {
        id: configRepresentation


        Rectangle {
            width:248
            height:28
            color:"transparent"
            radius:6
            antialiasing : true
            border.color:Kirigami.Theme.disabledTextColor

            Text {
                text:"Configure Weather"
                color:Kirigami.Theme.textColor
                anchors.centerIn:parent
                font.pointSize:16
                //bottomPadding:70
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onEntered: parent.border.color=Kirigami.Theme.linkColor
                onExited:parent.border.color=Kirigami.Theme.textColor
                onClicked:plasmoid.internalAction("configure").trigger()
                //onClicked:plasmoid.action("configure").trigger() //plasmoid.action("configure").trigger()  //plasmoid.configuration[0]
            }
            // plasmoid.configuration[0], can configure different sections of config
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
                    color: Kirigami.Theme.textColor
                }
                background: Rectangle {
                    color:Kirigami.Theme.activeBackgroundColor
                    radius:6
                    width:parent.width+20
                }
            }

            Text {
                text: weatherData.currently.lastUpdate
                color:Kirigami.Theme.disabledTextColor
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
                    onEntered: parent.color=Kirigami.Theme.linkColor
                    onExited:parent.color=Kirigami.Theme.textColor
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
                color:Kirigami.Theme.textColor
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
                    color:Kirigami.Theme.textColor
                    font.pointSize:20
                    antialiasing : true
                }

                Text {
                    id:summary
                    anchors.bottom:temp.bottom
                    text:weatherData.currently.conditions
                    color:Kirigami.Theme.textColor
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
                    color:Kirigami.Theme.textColor
                    font.pointSize:14
                    antialiasing : true

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: weatherData.currently.warnings ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: weatherData.currently.warnings ? true : false
                        onEntered:{
                            if (weatherData.currently.warnings) {
                                parent.color=Kirigami.Theme.linkColor
                                wtips.visible=true
                            }
                            else {
                                parent.color=Kirigami.Theme.textColor
                            }
                        }
                        onExited:{
                            if (weatherData.currently.warnings) {
                                parent.color=Kirigami.Theme.textColor
                                wtips.visible=false
                            }
                            else {
                                parent.color=Kirigami.Theme.textColor
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
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            antialiasing : true
                            width:79
                        }
                        Text {
                            text:"Humidity"
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            antialiasing : true
                            width:76
                        }
                        Text {
                            text:"Winds"
                            color:Kirigami.Theme.textColor
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
                            color:Kirigami.Theme.textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.apparentTemperature
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }

                        Text {
                            text:"\uf07a"
                            color:Kirigami.Theme.textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }

                        Text {
                            text:weatherData.currently.humidity
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }

                        Text {
                            text:"\uf050"
                            color:Kirigami.Theme.textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:10
                            bottomPadding:5
                        }
                        Text {
                            text:weatherData.currently.windGust > 0 && weatherData.currently.windGust > weatherData.currently.windSpeed ? weatherData.currently.windBearing+" at "+weatherData.currently.windSpeed + " to "+weatherData.currently.windGust +" "+ windUnits : weatherData.currently.windBearing+" at "+weatherData.currently.windSpeed+" "+windUnits
                            color:Kirigami.Theme.textColor
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
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            antialiasing : true
                            width:79
                        }
                        Text {
                            text:"Visibility"
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            antialiasing : true
                            width:76
                        }
                        Text {
                            text:"AQI"
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            antialiasing : true
                            width:106
                        }
                        Text {
                            text:"UVI"
                            color:Kirigami.Theme.textColor
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
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.dewPoint
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            antialiasing : true
                            width:48
                        }
                        Text {
                            text:"\uf047"
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:weatherData.currently.visibility + (units=="us" ? "mi":"km")
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            antialiasing : true
                            topPadding:2
                            width:48
                        }
                        Text {
                            text:"\uf063"
                            color:Kirigami.Theme.textColor
                            font.pointSize:12
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                        }
                        Text {
                            text:calcAQI()
                            color:Kirigami.Theme.textColor
                            font.pointSize:14
                            antialiasing : true
                            width:72
                        }
                        Text {
                            text:"\uf00d"
                            color:Kirigami.Theme.textColor
                            font.pointSize:11
                            font.family: 'weathericons'
                            antialiasing : true
                            width:5
                            topPadding:2
                        }
                        Text {
                            text:calcUVI()
                            color:Kirigami.Theme.textColor
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
                color: Kirigami.Theme.disabledTextColor
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
                    border.color:hourlyForecast.visible ? Kirigami.Theme.linkColor : Kirigami.Theme.disabledTextColor
                    radius:6

                    Text {
                        text:"Hourly"
                        color:hourlyForecast.visible ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
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
                    border.color:dailyForecast.visible ? Kirigami.Theme.linkColor : Kirigami.Theme.disabledTextColor
                    radius:6

                    Text {
                        text:"Daily"
                        color:dailyForecast.visible ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
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
                    spacing:7
                    Layout.alignment:Qt.AlignHCenter

                    Text {
                        id:timeofDay
                        text:weatherData.hourly[index].time
                        color:Kirigami.Theme.textColor
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
                        antialiasing:true
                    }

                    Text {
                        text:weatherData.hourly[index].precip
                        color:Kirigami.Theme.textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing : true
                    }

                    Text {
                        text:weatherData.hourly[index].temp
                        color:Kirigami.Theme.textColor
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
                        color:Kirigami.Theme.textColor
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
                        antialiasing:true
                        Layout.alignment:Qt.AlignHCenter
                    }

                    Text {
                        text:weatherData.daily[index].precip
                        color:Kirigami.Theme.textColor
                        Layout.alignment:Qt.AlignHCenter
                        font.pointSize:12
                        antialiasing:true
                    }

                    Text {
                        text:weatherData.daily[index].lowTemp+" | "+weatherData.daily[index].highTemp
                        color:Kirigami.Theme.textColor
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
                    clip:true
                    interactive:true
                    model:weatherData.hourly
                    onModelChanged:{
                        hourlyForecast.positionViewAtBeginning()
                        dailyForecast.visible=false
                        hourlyForecast.visible=true
                    }
                    delegate:hourlyList
                    ScrollBar.horizontal: ScrollBar {
                        id:scroll
                        policy: ScrollBar.AsNeeded
                        orientation: Qt.Horizontal
                        stepSize:.125
                        parent: hourlyForecast.parent
                        hoverEnabled: true
                        visible:false
                        active: hovered || pressed
                        interactive: false
                        anchors.fill:hourlyForecast
                        contentItem: Rectangle {
                            id:rect1
                            implicitWidth: 4
                            //implicitHeight:contentItem.height/4
                            radius:6
                            color: Kirigami.Theme.textColor
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
                            color: Kirigami.Theme.backgroundColor
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
                            onWheel: function (wheel){
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
