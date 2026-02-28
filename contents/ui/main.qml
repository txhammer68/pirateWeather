import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtNetwork
import org.kde.plasma.configuration
import org.kde.notification

// pirate weather widget
// api docs https://pirateweather.net/en/latest/API/
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

    property double currentVersion:Plasmoid.metaData.version
    property double updateVersion:0.0
    property string updateURL:"https://raw.githubusercontent.com/txhammer68/pirateWeather/refs/heads/main/metadata.json"

    property string weatherURL:"https://api.pirateweather.net/forecast/"+apiKey+"/"+latPoint+","+lonPoint+"?&units="+units+"&exclude=minutely,flags"
    property var weatherData:{}
    property bool weatherWarnings:false
    property bool weatherAlert:false
    property var iconCode:
        {"clear-day": '\uf00d',
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
               getData(updateURL)
               getData(weatherURL)
           }
           else Plasmoid.configurationRequired=true
    }

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    onWeatherURLChanged:getData(weatherURL)
    onUpdateIntervalChanged: weatherTimer.restart()
    onWeatherWarningsChanged:weatherWarnings ? weatherAlert=true : weatherAlert=false

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Refresh Data"
            icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "view-refresh" : "view-refresh"
            priority: Plasmoid.HighPriorityAction
            visible: true
            enabled: true
            onTriggered:getData(weatherURL)
        }
    ]

    Item {
        Notification {
            id: updateNotification
            componentName: "plasma_workspace"
            eventId: "notification"
            title: "Update"
            text: "Pirate Weather Update Available, Check Settings in Widget."
            iconName: "task-due"
            flags: Notification.CloseOnTimeout
            urgency: Notification.DefaultUrgency
            //timeout:5000
            onClosed: console.log("Notification closed.")
        }
    }

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true); // Use asynchronous!
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                let data = JSON.parse(xhr.responseText);
                 if (url == weatherURL) {
                    processWeatherData (data)
                }
                else processUpdateData (data)
            }
        }
        xhr.send();
    }

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            updateNotification.sendEvent()
        }
    }

    function processWeatherData (data) {
        if (data) {
            let hourly=[]
            let daily=[]
            let array={}
            let h1={}
            let d1={}
            let c1={
                lastUpdate:Qt.formatTime(new Date(data.currently.time*1000),"h:mm ap"),
                apparentTemperature:Math.round(data.currently.apparentTemperature)+"°",
                humidity:Math.round(data.currently.humidity*100)+"%",
                windBearing:degToCompass(data.currently.windBearing),
                windGust:data.currently.windGust != null ? Math.round(data.currently.windGust):0,
                windSpeed:Math.round(data.currently.windSpeed),
                icon:"../icons/"+data.currently.icon+".svg",
                panelIcon:data.currently.icon,
                temp:Math.round(data.currently.temperature)+"°",
                dewPoint:Math.round(data.currently.dewPoint)+"°",
                visibility:Math.round(data.currently.visibility),
                uvIndex:data.currently.uvIndex,
                ozone:data.currently.ozone,
                conditions:data.currently.summary,
                summary:data.hourly.summary,
                warnings:data.alerts.length > 0  ? true:false, // check if alert exists
                alertText:data.alerts.length > 0 ? "⚠️ "+data.alerts[0].title : "",
                weatherAlertsURL:data.alerts.length > 0 ? data.alerts[0].uri :"",
                weatherAlertsDesc:data.alerts.length > 0 ? data.alerts[0].description : ""
            }

            for (let x=0;x<data.hourly.data.length;x++) {
                h1={time:Qt.formatTime(new Date(data.hourly.data[x].time*1000),"h:mm ap"),
                    icon:"../icons/"+data.hourly.data[x].icon+".svg",
                    temp:Math.round(data.hourly.data[x].temperature)+"°",
                    precip:Math.round(data.hourly.data[x].precipProbability*100/10)*10+"%"}
                    hourly.push(h1)
            }

            for (let x=0;x<data.daily.data.length;x++) {
                d1={time:Qt.formatDate(new Date(data.daily.data[x].time*1000),"ddd"),
                    icon:"../icons/"+data.daily.data[x].icon+".svg",
                    lowTemp:Math.round(data.daily.data[x].temperatureLow)+"°",
                    highTemp:Math.round(data.daily.data[x].temperatureHigh)+"°",
                    precip:Math.round(data.daily.data[x].precipProbability*100/10)*10+"%"}
                    daily.push(d1)
            }

            array={currently:c1,hourly:hourly,daily:daily}
            weatherData=array
            weatherWarnings=weatherData.currently.warnings
            isConfigured=true
            Plasmoid.configurationRequired=false
            weatherTimer.restart()
        }
        else  {
            let c1={
                lastUpdate:"NA",
                apparentTemperature:"--",
                humidity:"--",
                windBearing:"--",
                windGust:0,
                icon:"../icons/na.png",
                panelIcon:"?",
                temp:"--",
                dewPoint:"--",
                visibility:"--",
                uvIndex:"--",
                ozone:"--",
                conditions:"No Data",
                summary:"No Data check settings or network connection",
                warnings:false,
                alertText:"",
                weatherAlertsURL:"--",
                weatherAlertsDesc:"--"
            }
            for (let x=0;x<7;x++) {
                h1={time:"--",
                    icon:"../icons/na.png",
                    temp:"--",
                    precip:"--"}
                    hourly.push(h1)
            }

            for (let x=0;x<7;x++) {
                d1={time:"--",
                    icon:"../icons/na.png",
                    lowTemp:"--",
                    highTemp:"--",
                    precip:"--"}
                    daily.push(d1)
            }
            array={currently:c1,hourly:hourly,daily:daily}
            weatherData=array
            weatherWarnings=false
            isConfigured=false
        }
    }

    function degToCompass(num) {
        var val = Math.floor((num / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        return arr[(val % 16)];
    }

    function calcAQI () {
        if (Math.round(weatherData.currently.ozone) > 299 && Math.round(weatherData.currently.ozone) < 501  ) {
            return "Good" }
        else if (Math.round(weatherData.currently.ozone) < 300 && Math.round(weatherData.currently.ozone) > 220 ) {
             return "Moderate" }
        else if (Math.round(weatherData.currently.ozone) <= 220) {
            return "Unhealthy" }
        else  {
            return "Unknown" }
    }

    function calcUVI () {
        if (weatherData.currently.uvIndex < 3) {
            return "Low" }
        else if (weatherData.currently.uvIndex < 6 ) {
             return "Moderate" }
        else if (weatherData.currently.uvIndex < 8 ) {
             return "High" }
        else if (weatherData.currently.uvIndex < 11 ) {
             return "Very High" }
        else if (weatherData.currently.uvIndex >= 11 ) {
             return "Extreme" }
        else return "Unknown"
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
        interval: 20*1000  // delay 20 secs for suspend to resume
        running: false
        repeat:  false
        onTriggered: {
            getData(weatherURL)
        }
    }
    Connections {
        target: NetworkInformation
        // Arguments must be explicitly listed
        function onReachabilityChanged(newReachability) {
            if (newReachability === NetworkInformation.Online) {
                suspendTimer.start();
            }
        }
    }
}
