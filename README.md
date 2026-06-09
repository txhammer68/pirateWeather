<p align="center">
    <img src="https://img.shields.io/badge/KDE_Plasma-6.0+-blue?style=for-the-badge&logo=kde" alt="KDE Plasma 6">
    <img src="https://img.shields.io/badge/license-GPL--2.0-green?style=for-the-badge" alt="License">
</p>

# pirateWeather
KDE Plasma 6 Plasmoid Weather Widget using Pirate Weather A Free, Flexable, and Open-Source Weather API <br>
Pirate Weather was developed on the closure of Dark Sky Weather providing an alternate open source option for weather data <br>

#### Compact View
 <img alt="preview" src="preview.png" width="40%">
 
#### Forecast View
 <img alt="previewFull" src="previewFull.png" width="40%">
 
Data Sources - https://docs.pirateweather.net/en/latest/DataSources/ <br>
Sign up for a free api key here https://pirate-weather.apiable.io/ <br>

* Install with
 ``` bash
git clone https://github.com/TxHammer68/pirateWeather /tmp/pirateWeather/ && kpackagetool6 -t Plasma/Applet -i /tmp/pirateWeather/
```
* Upgrade with
``` bash
git clone https://github.com/TxHammer68/pirateWeather /tmp/pirateWeather/ && kpackagetool6 -t Plasma/Applet -u /tmp/pirateWeather/
```
* Remove Widget with
``` bash
kpackagetool6 --remove pirateWeather --type Plasma/Applet
```

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
  * Verify settings/config after login
  * You can resize popup to get proper fit
  * hourly forecast is scrollable w/ mouse wheel. 
