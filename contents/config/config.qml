import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
         name: "Settings"
         icon: "configure"
         source: "ConfigWeather.qml"
    }
    ConfigCategory {
        name: "Setup"
        icon: "mdmsetup"
        source: "SetupConfig.qml"
    }
    ConfigCategory {
        name: "Debug"
        icon: "debug-run"
        source: "DebugConfig.qml"
    }
}
