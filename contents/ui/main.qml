import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmCore
import QtNetwork
import org.kde.plasma.configuration


// pirate weather widget
/// config not working, will not update after entering settings data

PlasmoidItem {
    id: root

    signal configurationChanged

    compactRepresentation:CompactRepresentation { }
    fullRepresentation:FullRepresentation { }
    //preferredRepresentation: isConstrained() ? Plasmoid.compactRepresentation : Plasmoid.fullRepresentation

    property bool isConfigured:false
    property string ipAddress:""
    property string apiKey: plasmoid.configuration.apiKey
    property string measUnits: detectSystemUnits()
    property int updateInterval: 15
    property string latPoint: ""
    property string lonPoint: ""

    property string url1:"https://api.ipify.org/?format=json"
    property string url2:"http://ip-api.com/json/"+ipAddress
    property string url3:"https://api.pirateweather.net/forecast/"+apiKey+"/"+latPoint+","+lonPoint+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"

    property var weatherData:{}
    property string lastUpdate:"--"
    property bool weatherWarnings:false
    property string alertText: ""

    property var iconCode:{"clear-day": '\uf00d',
        "clear-night": '\uf02e',
        "rain":'\uf019',
        "snow":'\uf01b',
        "sleet":'\uf0b5',
        "wind":'\uf021',
        "fog": '\uf014',
        "cloudy":'\uf013',
        "partly-cloudy-day":'\uf002',
        "partly-cloudy-night":'\uf031',
        "hail":'\uf015',
        "thunderstorm":'\uf01e',
        "tornado":'\uf056'}

       Component.onCompleted:{
        getData(url1)
    }

    onConfigurationChanged:refreshData()
    onApiKeyChanged:refreshData()

    Plasmoid.contextualActions: [
        PlasmCore.Action {
            text: "Refresh Data"
           icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "view-refresh" : "view-refresh"
            priority: Plasmoid.HighPriorityAction
            visible: true
            enabled: true
            onTriggered: refreshData()
        }
    ]

   function detectSystemUnits() {
       let measurementSystem = Qt.locale().measurementSystem
       return measurementSystem === 0 ? "si" : "us"
   }

    function refreshData () {
        getData(url1)
        weatherTimer.restart()
    }

    function getData(url) {  // read weather icon code from file
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url,false); // set Method and File
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    if (url==url1) {
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
                        processWeatherData(data)
                      }
                }
          }
        }
        xhr.send(); // begin the request
    }


    function processIPAddress (data) {
        if (typeof(data) != undefined) {
            ipAddress=data.ip
            if (ipAddress.length > 0) {
                getData(url2)
            }
        }
    }

    function processGeoData(data) {
        if (typeof(data) != undefined) {
            let lat = data.lat
            latPoint=lat
            let lon = data.lon
            lonPoint=lon
            if (lonPoint.length > 0) {
                getData(url3)
            }}
    }

    function processWeatherData (data) {
        if (typeof(data) != undefined) {//isConfigured=true
            weatherData=data
            if (data.latitude > 0) { // check if apiKey is valid/working
                isConfigured=true
            }
            else  isConfigured=false
            weatherDataChanged ()
            lastUpdate=Qt.formatTime(new Date(weatherData.currently.time*1000),"h:mm ap")
            weatherWarnings=weatherData.alerts.length > 0  ? true:false // check if alert exists
            alertText=weatherWarnings ? "⚠️   "+weatherData.alerts[0].title : ""
        }
    }

    function degToCompass(num) {
        var val = Math.floor((num / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        return arr[(val % 16)];
    }

    Timer {
        id: weatherTimer
        interval: updateInterval * 60 * 1000
        running: isConfigured
        repeat:  true
        triggeredOnStart:false
        onTriggered: {
            getData(url3)
        }
    }

    Timer {                 // timer to trigger update after wake from suspend mode
        id: suspendTimer
        interval: 20*1000;  // delay 20 secs for suspend to resume
        running: false
        repeat:  false
        onTriggered: {
            getData(url1)
            weatherTimer.restart()
        }
    }

    Connections {
        target:NetworkInformation
        onReachabilityChanged: {
            if (NetworkInformation.reachability == 4) {
                suspendTimer.start();
            }
        }
    }
}
