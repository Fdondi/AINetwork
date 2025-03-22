import QtQuick 2.15
import QtQuick.Controls 2.15
import AINetwork 1.0 // Import NewsFetcher

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: 400
    title: "AI News Social Network Simulation"

    NewsFetcher {
        id: newsFetcher // Create an instance of NewsFetcher
    }

    ListModel {
        id: newsModel
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
                    var news = newsFetcher.getNews();
                    console.info("News: " + news)
                    var newsData = news.data
                    newsModel.clear();
                    for (var i = 0; i < newsData.length; i++) {
                        newsModel.append({ title: newsData[i].title });
                    }
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
