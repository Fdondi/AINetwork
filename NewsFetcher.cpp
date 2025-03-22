#include "NewsFetcher.h"
#include "NewsFetcher.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QUrl>
#include <QDateTime>

NewsFetcher::NewsFetcher(QObject *parent) : QObject(parent), m_cacheFilePath("cache") {
    // Read the Mediastack API key from environment
    QByteArray key = qgetenv("MEDIASTACK_API_KEY");
    if (key.isEmpty()) {
        qFatal() << "Warning: MEDIASTACK_API_KEY environment variable is not set!";
    } else {
        m_apiKey = QString::fromUtf8(key);
    }
}

bool NewsFetcher::isCacheValid() {
    QFile file(m_cacheFilePath);
    if (!file.exists())
        return false;

    if (!file.open(QIODevice::ReadOnly))
    return false;

    // Expect the cache file to contain the fetched JSON object
    // with an extra field "cachedAt" recording the fetch time.
    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isObject())
        return false;

    QJsonObject obj = doc.object();
    if (!obj.contains("cachedAt"))
        return false;

    QDateTime cachedAt = QDateTime::fromString(obj.value("cachedAt").toString(), Qt::ISODate);
    // Consider valid if fetched within the last hour.
    return cachedAt.isValid() && cachedAt.secsTo(QDateTime::currentDateTimeUtc()) <= 3600;
}

void NewsFetcher::saveToCache(const QJsonDocument &doc) {
    QFile file(m_cacheFilePath);
    if (file.open(QIODevice::WriteOnly)) {
        // Wrap the news in an object so you can tag with a timestamp.
        QJsonObject root;
        root["cachedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
        // Assume the entire API response is in the document.
        // You can also insert extra data if needed.
        root["news"] = doc.object();
        file.write(QJsonDocument(root).toJson());
        file.close();
    }
}

QJsonDocument NewsFetcher::readFromCache() {
    QFile file(m_cacheFilePath);
    if (!file.open(QIODevice::ReadOnly))
        return QJsonDocument();


    QByteArray data = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        return QJsonDocument(obj.value("news").toObject());
    }
    return QJsonDocument();
}

QJsonDocument NewsFetcher::fetchNewsFromAPI() {
    // Compose your API URL. Depending on your Mediastack settings, you might
    // include parameters like access_key, limit, and sort.
    QString apiUrl = QString("http://api.mediastack.com/v1/news?access_key=%1&limit=5").arg(m_apiKey);
    QUrl url(apiUrl);
    QNetworkRequest request(url);

    QNetworkAccessManager manager;
    QNetworkReply *reply = manager.get(request);

    // Use event loop to block until finished (for a simple example).
    QEventLoop loop;
    QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QByteArray response = reply->readAll();

    qDebug() << "Downloaded response:" << response;  // Log the downloaded content

    reply->deleteLater();

    return QJsonDocument::fromJson(response);
}

QVariantMap NewsFetcher::getNews() {
    qDebug() << "GetNews called";
    if (isCacheValid()) {
        qDebug() << "Cache";
        return readFromCache().object().toVariantMap();
    } else {
        QJsonDocument freshNews = fetchNewsFromAPI();
        if (freshNews.isObject() && freshNews.object().contains("error")) {
            qDebug() << "Error in JSON response: " << freshNews.object().value("error").toString().toStdString();
        } else {
            saveToCache(freshNews);
        }
        return freshNews.object().toVariantMap();
    }
}
