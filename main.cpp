#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcessEnvironment>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Get the environment variable
    QString mistralApiKey = QProcessEnvironment::systemEnvironment().value("MISTRAL_API_KEY");

    // Expose it to QML
    engine.rootContext()->setContextProperty("mistralApiKey", mistralApiKey);

    const QUrl url(QStringLiteral("qrc:/AINetwork/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
