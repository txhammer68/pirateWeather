import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls
import org.kde.plasma.plasmoid
//import org.kde.plasma.plasmoid

 Item {
   id: debugConfigPage
   anchors.fill:parent

   property string msgText: `
   ### When reporting issues include this debug log
   ### Post issues to [gitHub pirateWeather/issues](https://github.com/txhammer68/pirateWeather/issues)
   ===========================================================`

   TextArea {
     readOnly: true
     anchors.top:parent.top
     anchors.left:parent.left
     width:parent.width*.95
     height:parent.height*.95
     anchors.margins:10
     wrapMode:Text.Wrap
     textFormat: TextEdit.MarkdownText
     color:Kirigami.Theme.textColor
     selectByMouse: true
     mouseSelectionMode: TextEdit.SelectCharacters
     font.pointSize:12
     antialiasing : true
     text:msgText +"\n \n" +
          "#### API URL: [" + plasmoid.configuration.api_url_base + "](" + plasmoid.configuration.api_url_base + ")\n" +
          "#### Version: "+ Plasmoid.metaData.version + "\n" +
          "#### Error Msg: " + plasmoid.configuration.errorMsg + "\n" +
           "==========================================================="
    onLinkActivated: (link) => {
            Qt.openUrlExternally(link)
        }
   }
}

