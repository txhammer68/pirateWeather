import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmCore
import QtNetwork
import org.kde.plasma.configuration

// pirate weather widget
// txhammer 01/2026

PlasmoidItem {
    id: root

    compactRepresentation:CompactRepresentation { }
    fullRepresentation:FullRepresentation { }

    property bool isConfigured:false
    property string apiKey: plasmoid.configuration.apiKey
    property int updateInterval: plasmoid.configuration.updateInterval
    property bool showForecast:plasmoid.configuration.forecastSel
    property string latPoint: plasmoid.configuration.latCode
    property string lonPoint: plasmoid.configuration.lonCode
    property string cityName:plasmoid.configuration.cityName
    property string regionName:plasmoid.configuration.regionName

    property string units:plasmoid.configuration.units
    property string windUnits:plasmoid.configuration.windUnits

    property string weatherURL:"https://api.pirateweather.net/forecast/"+apiKey+"/"+latPoint+","+lonPoint+"?&units="+units+"&exclude=minutely,flags"

    property var weatherData:{}
    property string lastUpdate:"--"
    property bool weatherWarnings:false
    property string alertText: ""
    property bool weatherAlert:false
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
        "tornado":'\uf056'
    }

    Component.onCompleted:{
           if (apiKey.length > 0) {
            getData(weatherURL)
           }
    }

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    onWeatherURLChanged:getData(weatherURL)
    onUpdateIntervalChanged: weatherTimer.restart()
    onWeatherWarningsChanged:weatherWarnings ? weatherAlert=true : weatherAlert=false

    Plasmoid.contextualActions: [
        PlasmCore.Action {
            text: "Refresh Data"
           icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "view-refresh" : "view-refresh"
            priority: Plasmoid.HighPriorityAction
            visible: true
            enabled: true
            onTriggered:getData(weatherURL)
        }
    ]

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url,false);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    if (url == weatherURL) {
                        let response = xhr.responseText
                        let data = JSON.parse(response)
                        processWeatherData(data)
                    }
                }
            }
        }
        xhr.send();
    }

    function processWeatherData (data) {
        if (typeof(data) != undefined) {
            if (data.latitude > 0) {
                weatherData=data
                weatherDataChanged ()
                lastUpdate=Qt.formatTime(new Date(weatherData.currently.time*1000),"h:mm ap")
                weatherWarnings=weatherData.alerts.length > 0  ? true:false // check if alert exists
                alertText=weatherWarnings ? "⚠️   "+weatherData.alerts[0].title : ""
                isConfigured=true
                weatherTimer.restart()
            }
            else  {
                isConfigured=false
                lastUpdate=="NA"
            }
        }
       return null
    }

    function degToCompass(num) {
        var val = Math.floor((num / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        return arr[(val % 16)];
    }

    function calcAQI () {
        if (Math.round(weatherData.currently.ozone) > 300 && Math.round(weatherData.currently.ozone) < 501  ) {
            return "Good" }
        else if (Math.round(weatherData.currently.ozone) < 299 && Math.round(weatherData.currently.ozone) > 220 ) {
             return "Moderate" }
        else if (Math.round(weatherData.currently.ozone) < 220) {
            return "Unhealthy" }
    }

    function calcUVI () {
        if (weatherData.currently.uvIndex < 3) {
            return "Low" }
        else if (weatherData.currently.uvIndex < 6 ) {
             return "Moderate" }
        else if (weatherData.currently.uvIndex < 9 ) {
             return "High" }
        else if (weatherData.currently.uvIndex < 11 ) {
             return "Very High" }
        else if (weatherData.currently.uvIndex > 11 ) {
             return "Extreme" }
    }

    Timer {
        id: weatherTimer
        interval: updateInterval * 60 * 1000
        running: isConfigured
        repeat:  true
        triggeredOnStart:false
        onTriggered: {
            getData(weatherURL)
        }
    }

    Timer {                 // timer to trigger update after wake from suspend mode
        id: suspendTimer
        interval: 20*1000;  // delay 20 secs for suspend to resume
        running: false
        repeat:  false
        onTriggered: {
            getData(weatherURL)
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
