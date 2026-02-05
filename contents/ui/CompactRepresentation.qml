import QtQuick
import QtQuick.Layouts

Item {
    id: compactRepresentation
    Layout.minimumWidth: 36
    Layout.preferredWidth: 64

    CompactItem {
        id: compactItem
        anchors.fill: parent
    }
}
