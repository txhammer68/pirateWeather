import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.configuration
import org.kde.kirigami.platform
import org.kde.plasma.plasma5support as Plasma5Support


Item {
    id: settingsPage

    property alias cfg_apiKey: apiNum.text
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_forecastSel: forecastSel.checked
    property alias cfg_idx:measSel.currentIndex
    property string cfg_units
    property string cfg_windUnits
    property alias cfg_latCode: latCode.text
    property alias cfg_lonCode: lonCode.text
    property alias cfg_cityName:cityName.text
    property alias cfg_regionName:regionName.text

    property string ipAddress:""
    property string url1:"https://api.ipify.org/?format=json"
    property string url2:"http://ip-api.com/json/"+ipAddress
    property string updateURL:"https://raw.githubusercontent.com/txhammer68/pirateWeather/refs/heads/main/metadata.json"
    property string updateCMD:"git clone https://github.com/TxHammer68/pirateWeather /tmp/pirateWeather/ && kpackagetool6 -t Plasma/Applet -u ./pirateWeather/"

    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property bool updateAvail:false
    property string updateMsg:"Updated Version Ready "+"("+updateVersion+")"

    Component.onCompleted:{
        getData(updateURL)
        measSel.currentIndex=cfg_idx
    }

    Text {
        id:appVer
        anchors.top:parent.top
        anchors.right:parent.right
        anchors.margins:10
        text:Plasmoid.metaData.version
        color:Theme.disabledTextColor
        font.pointSize:11
    }

    Column {
        id:settingsInputs
        anchors.top:parent.top
        anchors.left:parent.left
        topPadding:5
        leftPadding:20
        width:parent.width-50
        spacing:9

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
                text:"Select Update Interval"
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
                text:"Show Forecast"
                width:172
                color:Theme.textColor
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.CheckBox {
                id:forecastSel
                checked: true
                //text: qsTr("Third")
            }
        }

        Row {
            spacing:10
            Text {
                text:"Select Measurment Units"
                color:Theme.textColor
                topPadding:7
                width:172
                horizontalAlignment:Text.AlignLeft
            }
            QQC2.ComboBox {
                id:measSel
                width:196
                height:32
                displayText: currentIndex < 0 ? "Select Units" : currentText
                model: ["Canadian SI","Metric SI","UK SI","US Imperial"]
                onCurrentIndexChanged:formatMeasUnits ()
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
            border.color:apiNum.text.length > 1 ? Theme.linkColor:Theme.disabledTextColor
            radius:6

            Text {
                text:"Get Geo Codes"
                color:apiNum.text.length > 1 ? Theme.textColor:Theme.disabledTextColor
                anchors.centerIn:parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled:true
                onClicked:{
                    apiNum.text.length > 1 ? getData(url1):""
                }
            }
            Text {
                text:"Disable VPN First"
                color:apiNum.text.length > 1 ? Theme.textColor:Theme.disabledTextColor
                anchors.left:getGeoCodes.right
                anchors.bottom:getGeoCodes.bottom
                anchors.leftMargin:15
                anchors.bottomMargin:5
            }
        }

        Row {
            spacing:10
        Rectangle {
            id:updateWidget
            width:120
            height:32
            color:"transparent"
            border.color:updateAvail ? Theme.linkColor:Theme.disabledTextColor
            radius:6
            Text {
                text:"Update Widget"
                color:updateAvail ?  Theme.textColor:Theme.disabledTextColor
                anchors.centerIn:parent
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: updateAvail ? Qt.PointingHandCursor:Qt.ArrowCursor
                hoverEnabled:updateAvail
                onClicked:{
                    updateAvail ? executable.exec(updateCMD):""
                }
              }
            }
            Text {
                text:updateMsg
                color:Theme.textColor
                font.pointSize:11
                topPadding:5
                visible:updateAvail
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
                    else {
                        let response = xhr.responseText
                        let data = JSON.parse(response)
                        processUpdateData(data)
                    }
                }
            }
        }
        xhr.send();
    }

    function formatMeasUnits () {
        if (measSel.currentIndex == 0) {
            cfg_units="ca"
            cfg_windUnits=" kmh"
        }
        else if (measSel.currentIndex == 1) {
            cfg_units="si"
            cfg_windUnits=" mps"
        }
        else if (measSel.currentIndex == 2) {
            cfg_units="uk"
            cfg_windUnits=" mph"
        }
        else if (measSel.currentIndex == 3) {
            cfg_units="us"
            cfg_windUnits=" mph"
        }
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

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            updateAvail=true
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            let exitCode = data["exit code"]
            let exitStatus = data["exit status"]
            let stdout = data["stdout"]
            let stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }
}
