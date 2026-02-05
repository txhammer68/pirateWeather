import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
         name: "Settings"
         icon: "settings"
         source: "ConfigWeather.qml"
    }
    ConfigCategory {
        name: "Setup"
        icon: "mdmsetup"
        source: "SetupConfig.qml"
    }
}
