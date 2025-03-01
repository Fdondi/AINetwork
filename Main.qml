import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: 400
    title: "AI News Social Network Simulation"

    function simulateAIResponse(newsTitle, agentType) {
        switch(agentType) {
            case "ProGovernment":
                return "Official says: " + newsTitle + " is a positive signal for progress!";
            case "Skeptical":
                return "Skeptic remarks: " + newsTitle + " might hide contradictions.";
            case "YouthVoice":
                return "Youth advocate: " + newsTitle + " inspires change!";
            case "SpaceEnthusiast":
                return "Cosmic view: " + newsTitle + " makes me think of our endless possibilities in space!";
            default:
                return "Neutral: " + newsTitle;
        }
    }

    ListModel {
        id: newsModel
        ListElement { title: "Breaking News: Market Reaches All-Time High" }
        ListElement { title: "Update: New Technological Innovations Unveiled" }
        ListElement { title: "Alert: International Relations Tense Amid New Developments" }
    }

    header: ToolBar {
        id: appHeader
        Row {
            anchors.fill: parent
            spacing: 20

            Label {
                text: "AI News Feed"
                font.bold: true
                font.pointSize: 20
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                text: "Refresh"
                onClicked: {
                    newsModel.clear();
                    newsModel.append({ title: "Update: Economic Stimulus Boosts Job Creation" });
                    newsModel.append({ title: "Alert: Environmental Policies Spark Debate" });
                    newsModel.append({ title: "Tech: Renewable Energy Breakthrough Announced" });
                }
            }
        }
    }

    ListView {
        id: newsListView
        anchors {
            top: appHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        model: newsModel
        delegate: NewsItem {
            title: model.title
            listViewWidth: newsListView.width // Pass the ListView width
            listHorizontalCenter: newsListView.horizontalCenter
        }
    }
}
