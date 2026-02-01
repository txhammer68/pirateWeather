import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Item {
    id: compactRepresentation

    anchors.fill: parent

    CompactItem {
        id: compactItem
        inTray: false
    }
}
