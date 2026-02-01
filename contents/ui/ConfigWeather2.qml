import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.configuration
import org.kde.kirigami.platform

Item {
     id: settingsPage
     property alias cfg_apiKey: apiNum.text
     property alias cfg_measUnits:unitsSel.value
     // property string cfg_lang:'en'
     property alias cfg_interval:intervalSel.value
     property alias cfg_latPoint:latNum.text
     property alias cfg_lonPoint:lonNum.text

     // property string url1:"https://api.ipify.org/?format=json"
     // property string url2:"http://ip-api.com/json/"+ipKey

     property string url1:"http://ip-api.com/json/?fields=lat,lon"
     // http://ip-api.com/json/24.48.0.1

     signal configurationChanged
     //onConfigurationChanged:plasmoid.configuration.writeConfig()

     QtObject {
         id: unitsSel
         property var value
     }

     Column {
         id:settingsInputs
         anchors.top:parent.top
         anchors.left:parent.left
         topPadding:5
         leftPadding:40
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
             text:"Signup Here"
             color:Theme.textColor
             font.pointSize:14
             topPadding:5
             MouseArea {
                 anchors.fill: parent
                 hoverEnabled: true
                 cursorShape:Qt.PointingHandCursor
                 onEntered: parent.color=Theme.viewHoverColor
                 onExited: parent.color=Theme.viewTextColor
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
                 //onAccepted: Plasmoid.configuration.writeConfig()
             }
         }

         Row {
             spacing:10
             Text {
                 text:"Select Measurement Units"
                 color:Theme.textColor
                 topPadding:7
                 width:172
                 horizontalAlignment:Text.AlignLeft
             }
             QQC2.ComboBox {
                 //id:unitsSel
                 width:220
                 height:28
                 textRole: "text"
                 valueRole: "value"
                 displayText:model[1]
                 model:[
                 {text: i18n("Metric"), value: "si"},
                 {text: i18n("Imperial"), value: "us"}
                 ]
                 onActivated: unitsSel.value = currentValue
                 Component.onCompleted: currentIndex = indexOfValue(unitsSel.value)
             }
         }

         Row {
             spacing:10
             Text {
                 topPadding:7
                 width:172
                 text:"Update Interval Minutes"
                 color:Theme.textColor
                 horizontalAlignment:Text.AlignLeft
             }

             QQC2.SpinBox {
                 id:intervalSel
                 value:15
                 to:60
                 from:10
                 editable: true
             }
         }

         Row {
             spacing:10
             Text {
                 text:"Enter Latitude Geo Code"
                 color:Theme.textColor
                 topPadding:7
                 width:172
                 horizontalAlignment:Text.AlignLeft
             }
             QQC2.TextField {
                 id: latNum
                 placeholderText: "Enter Latitude Geo Code"
                 placeholderTextColor:Theme.disabledTextColor
                 //onAccepted: latNum.text
             }
         }

         Row {
             spacing:10
             Text {
                 text:"Enter Longitude Geo Code"
                 color:Theme.textColor
                 topPadding:7
                 width:172
                 horizontalAlignment:Text.AlignLeft
             }

             QQC2.TextField {
                 id: lonNum
                 placeholderText: "Enter Longitude Geo Code"
                 placeholderTextColor:Theme.disabledTextColor
                 //onAccepted: Plasmoid.configuration.writeConfig()
             }
         }
        Row {
            spacing:10
         QQC2.Button {
             text: "Get Geo Codes"
             width:142
             height:24
             onClicked:getData(url1)
             topPadding:40
             leftPadding:20
         }

         Text {
             text:"  Disable VPN First"
             color:"#d54a13"
             topPadding:3
         }
        }
     }

     function getData(url) {  // read weather icon code from file
         let xhr = new XMLHttpRequest();
         xhr.open("GET", url,false); // set Method and File
         xhr.onreadystatechange = function () {
             if (xhr.readyState === 4) {
                 if (xhr.status === 200) {
                     let response = xhr.responseText;
                     let data = JSON.parse(response);
                     processGeoData(data);
                 }
             }
         }
         xhr.open("GET", url,false); // set Method and File
         xhr.send(); // begin the request
     }

     function processGeoData(data) {
         let lat = data.lat
         latNum.text=lat
         let lon = data.lon
         lonNum.text=lon
     }
}
