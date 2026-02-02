import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.configuration
import org.kde.kirigami.platform

Item {
    id: settingsPage

    property alias cfg_apiKey: apiNum.text
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_latCode: latCode.text
    property alias cfg_lonCode: lonCode.text
    property alias cfg_cityName:cityName.text
    property alias cfg_regionName:regionName.text
    property string ipAddress:""
    property string url1:"https://api.ipify.org/?format=json"
    property string url2:"http://ip-api.com/json/"+ipAddress

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
            text:">>  Get API Key"
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
            }
        }

        Row {
            spacing:10
            Text {
                text:"Enter Update Interval"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
        QQC2.SpinBox {
            id: updateInterval
            from: 10
            to:60
            value:15
          }
        }

        Row {
            spacing:10
            Text {
                text:"Enter Latitude Code"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.TextField {
                id: latCode
                placeholderText: "Enter Latitude Code"
                placeholderTextColor:Theme.disabledTextColor
            }
        }
        Row {
            spacing:10
            Text {
                text:"Enter Longtitude Code"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.TextField {
                id: lonCode
                placeholderText: "Enter Longtitude Code"
                placeholderTextColor:Theme.disabledTextColor
            }
        }

        Row {
            spacing:10
            Text {
                text:"City"
                width:172
                color:Theme.textColor
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.TextField {
                id:cityName
                placeholderText: "Enter City Name"
                placeholderTextColor:Theme.disabledTextColor
            }
        }

        Row {
            spacing:10
            Text {
                text:"Region"
                width:172
                color:Theme.textColor
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.TextField {
                id:regionName
                placeholderText: "Enter Region Name"
                placeholderTextColor:Theme.disabledTextColor
            }
        }

        Rectangle {
            id:getGeoCodes
            width:120
            height:32
            color:"transparent"
            border.color:apiNum.text.length == 40 ? Theme.linkColor:Theme.disabledTextColor
            radius:6

            Text {
                text:"Get Geo Codes"
                color:Theme.textColor
                anchors.centerIn:parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onClicked:{
                    apiNum.text.length == 40 ? getData(url1):""
                }
            }
            Text {
                text:"Disable VPN First"
                color:apiNum.text.length == 40 ? Theme.textColor:Theme.disabledTextColor
                anchors.left:getGeoCodes.right
                anchors.bottom:getGeoCodes.bottom
                anchors.leftMargin:15
                anchors.bottomMargin:5
            }
        }
    }

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url,false);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    if (url == url1) {
                        let response = xhr.responseText
                        let data = JSON.parse(response)
                        processIPAddress(data)
                    }
                    else if (url == url2) {
                        let response = xhr.responseText
                        let data = JSON.parse(response)
                        processGeoData(data)
                    }
                }
            }
        }
        xhr.send();
    }

    function processIPAddress (data) {
        if (typeof(data) != undefined) {
            ipAddress=data.ip
            if (ipAddress.length > 0) {
                getData(url2)
            }
        }
        return null
    }

    function processGeoData(data) {
        if (typeof(data) != undefined) {
            let lat = data.lat
            latCode.text=lat
            let lon = data.lon
            lonCode.text=lon
            let c1=data.city
            cityName.text=c1
            let r1=data.regionName
            regionName.text=r1
        }
    return null
    }
}
