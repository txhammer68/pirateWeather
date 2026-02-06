import QtQuick
import org.kde.kirigami.platform

Item {
  id:setup
  property string setupText:"
* Install widget to panel or desktop floating
* Right click on widget to configure
* Enter API Key
* Select mesurement units
* Select Update Interval (10-60 mins)
* Uses IP address to get geo coordinates - Disable VPN on first install/use
* Click Get GeoCodes to get Geo Coordinates Locatiion
* Click on the top right corner (last update time) to refresh data or Right Click on widget to Refresh Data
* Added Update Widget Button in the Config Screen
  * Logout after update for update to be applied
  * Verify settings/config after login"

  Text {
    leftPadding:20
    width:setup.width*.95
    //Layout.fillWidth : true
    wrapMode:Text.Wrap
    color:Theme.textColor
    font.pointSize:14
    antialiasing : true
    text:setupText
  }
}

