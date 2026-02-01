import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmCore
import QtNetwork
import org.kde.plasma.configuration
//import org.kde.kirigami as Kirigami

// pirate weather widget
/// config not working, will not update after entering settings data

PlasmoidItem {
    id: root
    signal configurationChanged
    //width: 420 //Kirigami.Units.gridUnit * 8
    //height: 320 // Kirigami.Units.gridUnit * 4
    // Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

    //compactRepresentation: Loader {
       // id: compactLoader

        //property bool containsMouse: item?.containsMouse ?? false
        //Layout.minimumWidth: item.Layout.minimumWidth
       // Layout.minimumHeight: item.Layout.minimumHeight
        //Layout.preferredWidth: item.Layout.preferredWidth
       // Layout.preferredHeight: item.Layout.preferredHeight
        //Layout.maximumWidth: item.Layout.maximumWidth
        //Layout.maximumHeight: item.Layout.maximumHeight
        //sourceComponent: isConfigured ? 'CompactRepresentation.qml' : undefined
    //}

   // fullRepresentation: Loader {
       // id: fullRepLoader

        //property bool containsMouse: item?.containsMouse ?? false
       // Layout.minimumWidth: item.Layout.minimumWidth
        //Layout.minimumHeight: item.Layout.minimumHeight
        //Layout.preferredWidth: item.Layout.preferredWidth
        //Layout.preferredHeight: item.Layout.preferredHeight
        //Layout.maximumWidth: item.Layout.maximumWidth
        //Layout.maximumHeight: item.Layout.maximumHeight
        //sourceComponent: isConfigured ? 'FullRepresentation.qml' : undefined
    //}

    compactRepresentation:CompactRepresentation { }
    fullRepresentation:FullRepresentation { }
    //preferredRepresentation: isConstrained() ? Plasmoid.compactRepresentation : Plasmoid.fullRepresentation

    property bool isConfigured:false
    readonly property string apiKey: plasmoid.configuration.apiKey
    readonly property string measUnits: plasmoid.configuration.measUnits
    readonly property string updateInterval: plasmoid.configuration.interval
    readonly property string latPoint: plasmoid.configuration.latPoint
    readonly property string lonPoint: plasmoid.configuration.lonPoint
    //property string apiKey:"sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw"
    //property string measUnits:"us"
    //property int updateInterval:10
    //readonly property string latPoint: "29.668"
    //readonly property string lonPoint: "-95.068"
    //property string url1:"http://ip-api.com/json/?fields=lat,lon";
    //property string url2:"https://api.pirateweather.net/forecast/"+apiKey+"/"+geoCords+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"

    property string url1:"https://api.pirateweather.net/forecast/"+apiKey+"/"+latPoint+","+lonPoint+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"

    property var weatherData:{}
    property string lastUpdate:"--"
    property bool weatherWarnings:false
    property string alertText: ""


    Component.onCompleted:{
       checkConfigured()
        //calcLayout()
        //isConfigured=true
    }

    onConfigurationChanged:refreshData()

   // Connections {
      //  target: Plasmoid.configuration
     //   function onApiKeyChanged() { refreshData (); }
     //   function onMeasUnitsChanged() { refreshData (); }
     //   function onUpdateIntervalChanged() { refreshData (); }
     //   function onLonPointChanged() { refreshData (); }
    //    function onLatPointChanged() { refreshData (); }
    //}

// this should be working,more wierdness... qt/qml is full of bugs
    onApiKeyChanged:checkConfigured ()
    onMeasUnitsChanged:checkConfigured ()
    onUpdateIntervalChanged:checkConfigured ()
    onLonPointChanged:checkConfigured ()
    onLatPointChanged:checkConfigured ()
    //onConfigurationChanged:refreshData ()

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

   //WeatherData{id:wData}

   function checkConfigured () {
       if (apiKey.length > 0 && measUnits.length > 0 && updateInterval > 0 && lonPoint.length > 0 && latPoint.length > 0){
           ConfigurationChanged()
           getData(url1)
       }
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
                    let response = xhr.responseText
                    let data = JSON.parse(response)
                    if (data.latitude > 0) {
                        isConfigured=true
                        processWeatherData(data)
                      }
                      else {
                          isConfigured=false
                      }
                    }
            }
        }
        xhr.send(); // begin the request
    }

    function processWeatherData (data) {
                if (typeof(data) != undefined) {//isConfigured=true
                    weatherData=data
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

    //function calcLayout() {
       // if (Plasmoid.formFactor == PlasmaCore.Types.Horizontal) {
        //    preferredRepresentation = compactRepresentation
       //}
       // else if (Plasmoid.formFactor == PlasmaCore.Types.Vertical) {
         //   preferredRepresentation = compactRepresentation
       // }
       // else if (Plasmoid.location == PlasmaCore.Types.Desktop) {
          //  preferredRepresentation = fullRepresentation
       // }
       //else if (Plasmoid.location == PlasmaCore.Types.Floating) {
         //   preferredRepresentation = fullRepresentation
       // }
   // }

    //function isConstrained() {  // test for floating or panel placement of widget
        //return (Plasmoid.formFactor == PlasmaCore.Types.Vertical || Plasmoid.formFactor == PlasmaCore.Types.Horizontal);
   // }

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
