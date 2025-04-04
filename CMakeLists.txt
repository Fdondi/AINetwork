cmake_minimum_required(VERSION 3.16)

project(AINetwork VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appAINetwork
    main.cpp
)

qt_add_qml_module(appAINetwork
    URI AINetwork
    VERSION 1.0
    QML_FILES
        Main.qml
        NewsItem.qml
        aiService.js
        agentConfig.xml
    SOURCES
        NewsFetcher.h
        NewsFetcher.cpp
)

# Explicitly add your own resources.qrc
qt_add_resources(appAINetwork "resources.qrc")

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appAINetwork PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appAINetwork
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appAINetwork
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appAINetwork
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
