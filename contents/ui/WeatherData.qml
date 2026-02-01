import QtQuick
import org.kde.plasma.core
import QtNetwork

Item {
    id: wData
    property var weatherData:{}
    property var lastUpdate:"--"
    property bool weatherWarnings:false
    property string alertText: ""

    //property string url2:" https://api.pirateweather.net/forecast/sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw/29.668,-95.069?exclude=minutely,flags"
    //Component.onCompleted:getData(url1)

    function getData(url) {  // read weather icon code from file
      let xhr = new XMLHttpRequest();
      xhr.open("GET", url,false); // set Method and File
      xhr.onreadystatechange = function () {
          if (xhr.readyState === 4) {
              if (xhr.status === 200) {
                    let response = xhr.responseText
                    data = JSON.parse(response)
                    processWeatherData(data)
          }
        }
      }
      xhr.send(); // begin the request
   }

   function processWeatherData (data) {
       if (typeof data != undefined) {
           if (data.latitude > 0) {
                isConfigured=true
                weatherData=data
                lastUpdate=Qt.formatTime(new Date(weatherData.currently.time*1000),"h:mm ap")
                weatherWarnings=weatherData.alerts.length > 0  ? true:false // check if alert exists
                alertText=weatherWarnings ? "⚠️   "+weatherData.alerts[0].title : ""
           }
       }
       else {
            lastUpdate="--"
       }
   }

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

    function ozone_lvl(x) {  // levels not right need dobson units conversion

            if (x < 60)
                ozone="Good"
            else if ( x <  120)
                ozone="Fair"
            else if ( x < 180)
                ozone="Moderate"
            else if ( x < 240 )
                ozone="Poor"
            else if ( x > 240)
                ozone="Very Poor"
    }

        function  moon_icon(moon_phase) {
            if (moon_phase == 0)
                return "new_moon"
            if (moon_phase < .125)
                return "waxing_crescent_moon"
            if (moon_phase < .25)
                return "first_quarter_moon"
            if (moon_phase < .48)
                return "waxing_gibbous_moon"
            if (moon_phase < .52)
                return "full_moon"
            if (moon_phase < .625)
                return "waning_gibbous_moon"
            if (moon_phase < .75)
                return "last_quarter_moon"
            if (moon_phase < 1)
                return "waning_crescent_moon"
            return "crescent_moon"

        }

    function degToCompass(num) {
        var val = Math.floor((num / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
    return arr[(val % 16)];
}

Timer {                  // timer to trigger update for weather info
    id: weatherTimer
    interval: updateInterval * 60 * 1000
    running: isConfigured
    repeat:  true
    triggeredOnStart:false
    onTriggered: {
        getData(url1)
    }
}

Timer {       // timer to trigger update after wake from suspend mode
    id: suspendTimer
    interval: 20*1000;///delay 20 secs for suspend to resume
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
