import QtQuick 2.15
import "aiService.js" as AIService
import QtQml.XmlListModel

Rectangle {
    id: newsItem
    property real listViewWidth: 0
    property real listHorizontalCenter: 0
    width: listViewWidth - 20
    height: newsColumn.implicitHeight + 16
    color: "lightgray"
    border.width: 1
    border.color: "darkgray"
    radius: 8
    anchors.horizontalCenter: listHorizontalCenter
    anchors.margins: 8

    property var dataJson: { "title": "Not found" }

    Column {
        id: newsColumn
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        width: parent.width

        Text {
            text: newsItem.dataJson.title
            font.bold: true
            font.pointSize: 16
            wrapMode: Text.Wrap
        }

        Text {
            text: newsItem.dataJson.description
            font.pointSize: 9
            wrapMode: Text.Wrap
            color: "red"
        }

        Text {
            text: newsItem.dataJson.content
            font.pointSize: 11
            wrapMode: Text.Wrap
        }

        XmlListModel {
            id: agentModel
            source: "qrc:/AINetwork/agentConfig.xml"
            query: "/agents/agent"

            XmlListModelRole { name: "agentName"; elementName: "name" }
            XmlListModelRole { name: "agentColor"; elementName: "color" }
            XmlListModelRole { name: "agentDescription"; elementName: "description" }
        }

        Repeater {
            id: repeater
            model: agentModel
            delegate: Text {
                id: responseText
                width: parent.width
                text: "Loading..."
                color: agentColor
                font.pointSize: 12
                wrapMode: Text.WordWrap
                elide: Text.ElideNone

                Timer {
                    id: retryTimer
                    repeat: false
                    running: false
                    property var currentParams
                    property var currentCallback
                    property int currentDelay: 100

                    // Helper function to get randomized delay
                    function getRandomizedDelay() {
                        // Creates a range of ±50% of the current delay
                        let min = currentDelay * 0.75
                        let max = currentDelay * 1.25
                        return Math.floor(Math.random() * (max - min + 1)) + min
                    }

                    onTriggered: {
                        AIService.callAI(currentParams, this, mistralApiKey, currentCallback)
                    }
                }

                Component.onCompleted: {
                    AIService.fetchAICommentary(
                        newsItem.dataJson,
                        agentName,
                        agentDescription,
                        retryTimer,
                        mistralApiKey,
                        function(commentary) {
                            responseText.text = commentary;
                        }
                    );
                }
            }
        }
    }
}
