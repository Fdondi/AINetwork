#ifndef NEWSFETCHER_H
#define NEWSFETCHER_H

#include <QString>
#include <QJsonDocument>
#include <qqmlintegration.h>

class NewsFetcher: public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    explicit NewsFetcher(QObject *parent = nullptr);
    // Returns the JSON document with the news data.
    Q_INVOKABLE QVariantMap getNews();
private:
    QString m_cacheFilePath;
    QString m_apiKey;
    // Returns true if cached data is valid (i.e., re-fetched if older than 1h).
    bool isCacheValid();


    // Performs the API call to Mediastack. (You can make this asynchronous.)
    QJsonDocument fetchNewsFromAPI();

    // Writes the fetched JSON to the cache file.
    void saveToCache(const QJsonDocument &doc);

    // Reads JSON from the cache file.
    QJsonDocument readFromCache();
};

Q_DECLARE_METATYPE(NewsFetcher*)

#endif // NEWSFETCHER_H
