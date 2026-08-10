import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtNetwork
import org.kde.plasma.configuration
import org.kde.notification

/*
 * txhammer 08/2026
 * Pirate Weather Widget for Plasma 6
 * api docs https://pirateweather.net/en/latest/API/
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


PlasmoidItem {
    id: root

    compactRepresentation:CompactRepresentation { }
    fullRepresentation:FullRepresentation { }

    toolTipMainText: weatherData.currently.warnings ?  weatherData.currently.alertText : weatherData.currently.summary
    toolTipSubText:weatherData.currently.warnings ?  weatherData.currently.weatherAlertsDesc : ""

    property bool isConfigured:false
    property string apiKey: plasmoid.configuration.apiKey
    property int updateInterval: Number(plasmoid.configuration.updateInterval)
    property bool showForecast:plasmoid.configuration.forecastSel
    property string latPoint: plasmoid.configuration.latCode
    property string lonPoint: plasmoid.configuration.lonCode
    property string cityName:plasmoid.configuration.cityName
    property string regionName:plasmoid.configuration.regionName
    property string units:plasmoid.configuration.units
    property string windUnits:plasmoid.configuration.windUnits
    property bool autoUpdate:plasmoid.configuration.chkBoxUpdate

    property real currentVersion:Plasmoid.metaData.version
    property real updateVersion:0.0
    property string updateURL:"https://raw.githubusercontent.com/txhammer68/pirateWeather/refs/heads/main/metadata.json"

    property string weatherURL:plasmoid.configuration.api_url
    property var weatherData:{}
    property bool weatherWarnings:false
    property bool weatherAlert:false
    property string notificationTitle:""
    property string notificationMsg:""
    property string notificationIcon:""

    readonly property real panelThickness: // useed to determine font size in panel
    (Plasmoid.formFactor === PlasmaCore.Types.Vertical)
    ? parent.width : parent.height

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

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    Component.onCompleted:{
        if ( checkConfig() ) getData(weatherURL); else Plasmoid.configurationRequired = true;
        //weatherURL.length > 116 ? getData(weatherURL):Plasmoid.configurationRequired=true
        autoUpdate ? getData(updateURL):""
    }

    function checkConfig() {
        return apiKey && apiKey.length > 10 && latPoint && lonPoint
    }

    onWeatherURLChanged: if (checkConfig()) getData(weatherURL); else Plasmoid.configurationRequired = true;
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
            title: notificationTitle
            text: notificationMsg
            iconName: notificationIcon
            flags: Notification.CloseOnTimeout
            urgency: Notification.DefaultUrgency
            //timeout:5000
            onClosed: console.log("Notification closed.")
        }
    }

    function getData(url) {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        // Set a timeout (5 seconds) so the widget doesn't hang on a dead connection
        xhr.timeout = 5000;
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText);
                        if (url === weatherURL) {
                            processWeatherData (data)
                        } else if (url === updateURL) {
                            processUpdateData(data)
                        }
                    } catch (e) {
                        notificationTitle="Pirate Weather Error"
                        notificationMsg="Failed to parse JSON Data"
                        notificationIcon="dialog-error"
                        updateNotification.sendEvent()
                        console.error("Failed to parse JSON from:", url, e);
                        xhr.onreadystatechange = null;
                        xhr=null;
                    } finally {
                        xhr.onreadystatechange = null;
                        xhr=null;
                    }
                } else {
                    // Handle API Down or Network Error (404, 500, etc.)
                    notificationTitle="Pirate Weather Warning"
                    notificationMsg="API Key Error:"
                    notificationIcon="dialog-error"
                    updateNotification.sendEvent()
                    console.warn("API Error:", xhr.status, "URL:", url);
                    isConfigured=false
                    xhr.onreadystatechange = null;
                    xhr=null;
                    Plasmoid.configurationRequired = true
                }
            }
        };

        xhr.ontimeout = function () {
            notificationTitle="Pirate Weather Warning"
            notificationMsg="Request timed out, check network connection"
            notificationIcon="dialog-error"
            updateNotification.sendEvent()
            console.error("Request timed out for:", url);
            xhr.onreadystatechange = null;
            xhr=null;
        };

        xhr.onerror = function () {
            notificationTitle="Pirate Weather Warning"
            notificationMsg="Request timed out, check network connection"
            notificationIcon="dialog-error"
            updateNotification.sendEvent()
            console.error("Network error occurred while fetching:", url);
            xhr.onreadystatechange = null;
            xhr=null;
        };

        xhr.send();
    }

    function processUpdateData (data) {
        updateVersion=data.KPlugin.Version
        if (updateVersion > currentVersion) {
            notificationTitle="Pirate Weather Update"
            notificationMsg="Pirate Weather Update Available, Check Settings in Widget."
            notificationIcon="task-due"
            updateNotification.sendEvent()
        }
    }

    function processWeatherData (data) {
        let hourly=[]
        let daily=[]
        let array={}
        let h1={}
        let c1={}
        let d1={}
        if (data) {
            c1={
                lastUpdate:Qt.formatTime(new Date(data.currently.time*1000),"h:mm ap"),
                apparentTemperature:(data.currently.temperature > 200 || data.currently.temperature < -200) ? "NA":Math.round(data.currently.apparentTemperature)+"°",
                humidity: (data.currently.humidity > 200 || data.currently.humidity < 0) ? "NA" : Math.round(data.currently.humidity*100)+"%",
                windBearing:degToCompass(data.currently.windBearing),
                // // The value is either null, undefined, or NaN
                windGust:(data.currently.windGust === null || Number.isNaN(data.currently.windGust) || (data.currently.windGust > 300 || data.currently.windGust < 0)) ? "NA" : Math.round(data.currently.windGust),
                windSpeed: (data.currently.windSpeed === null || Number.isNaN(data.currently.windGust) || (data.currently.windSpeed > 300 || data.currently.windSpeed < 0)) ? "NA":Math.round(data.currently.windSpeed),
                icon:"../icons/"+data.currently.icon+".svg",
                panelIcon:data.currently.icon,
                temperature: (data.currently.temperature > 200 || data.currently.temperature < -200) ? "NA":Math.round(data.currently.temperature)+"°",
                dewPoint: (data.currently.dewPoint > 200 || data.currently.dewPoint < -200) ? "NA":Math.round(data.currently.dewPoint)+"°",
                visibility: (data.currently.visibility > 200 || data.currently.visibility < 0) ? "NA":Math.round(data.currently.visibility),
                uvIndex:data.currently.uvIndex,
                ozone:data.currently.ozone,
                aqi:Number(data.currently.airQualityIndex),
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
                temperature:"--",
                dewPoint:"--",
                visibility:"--",
                uvIndex:undefined,
                ozone:undefined,
                aqi:undefined,
                conditions:"No Data",
                summary:"No Data check settings or network connection",
                warnings:false,
                alertText:"",
                weatherAlertsURL:"--",
                weatherAlertsDesc:"--"
            }
            for (let x=0;x<12;x++) {
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
            console.error("Data API Error w/ Pirate Weather")
            console.error(weatherURL)
        }
    }

    function degToCompass(num) {
        var val = Math.floor((num / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        return arr[(val % 16)];
    }

    function calcAQI() {
        const o = Number(weatherData.currently.aqi);
        // Validate that the input is a valid number
        if (!Number.isFinite(o)) return "NA";
        const ranges = [
            { max: 50, label: "Good" },
            { max: 100, label: "Fair" },
            { max: 150, label: "Moderate" },
            { max: 200, label: "Unhealthy" },
            { max: 300, label: "Extreme" }
        ];

        // Find the first range where the aqi value is less than or equal to the max
        const match = ranges.find(range => o <= range.max);
        // Return the matched label, or "Extreme!!!" if it exceeds all maximums
        return match ? match.label : "Extreme!!!";
    }

    function calcUVI() {
        var u = Number(weatherData.currently.uvIndex)
        if (!isFinite(u)) return "NA"
        if (u < 3) return "Low"
        else if (u < 6) return "Moderate"
        else if (u < 8) return "High"
        else if (u < 11) return "Very High"
        else return "Extreme"
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
