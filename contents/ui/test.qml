import QtQuick
import QtQuick.Controls
Rectangle {
width:600
height:600
color:"black"



// https://api.pirateweather.net/forecast/sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw/29.668,-95.069?exclude=minutely,flags

// https://api.pirateweather.net/forecast/sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw/29.668,-95.069?&units=us&lang=en&exclude=minutely,flags
//property string geoCords:""
//property string apiKey:"sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw"
//property string measUnits:"us"
//property string url1:"http://ip-api.com/json/?fields=lat,lon";
//property string url2:"https://api.pirateweather.net/forecast/"+apiKey+"/"+geoCords+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"
//property bool dataErrors:false

property string apiKey:"sEXf6e3tRy8Q5dcswF6SB6U7iuL1Synz80v1N0yw"
property string measUnits:"us"
property int updateInterval:10
readonly property string latPoint: "29.668"
readonly property string lonPoint: "-95.068"
//property string url1:"http://ip-api.com/json/?fields=lat,lon";
//property string url2:"https://api.pirateweather.net/forecast/"+apiKey+"/"+geoCords+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"

property string url1:"https://api.pirateweather.net/forecast/"+apiKey+"/"+latPoint+","+lonPoint+"?&units="+measUnits+"&lang=en"+"&exclude=minutely,flags"

property var weatherData:{}

Component.onCompleted:{
    getData(url1)
    //getData(url2)
}

function getData(url) {

    let request = new XMLHttpRequest();
    request.open("GET", url, true);
    request.onreadystatechange = function () {
        if (request.readyState === 4) {
            if (request.status === 200) {
                if (url == url1) {
                try {
                    let data = JSON.parse(request.responseText);
                    processGeoData(data);
                } catch (error) {
                    console.error("Error", error);
                    dataErrors=true
                   }
                }
            else {
                try {
                    let data = JSON.parse(request.responseText);
                    processWeatherData(data);
                } catch (error) {
                    console.error("Error", error);
                    dataErrors=true
                }
            }

            } else {
                console.error(`Error: ${request.status}`);
                dataErrors=true
            }
        }
    };

    request.onerror = function () {
        console.error("Error");
    };

    request.send();
}

    function processGeoData(data) {
        let latitud = data.lat
        let longitud = data.lon
        geoCords = `${latitud}, ${longitud}`
        dataErrors=false
        getData(url2)
    }

    function processWeatherData (data) {
        weatherData=data
        dataErrors=false
    }

    TextField {
        text:url1// weatherData.currently.summary
        color:"white"
    }
}
