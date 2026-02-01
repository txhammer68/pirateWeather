import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
         name: "Settings"
         icon: "settings"
         source: "ConfigWeather.qml"
    }
}
