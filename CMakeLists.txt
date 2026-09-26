cmake_minimum_required(VERSION 3.16)
project(lingmo-welcome VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(GNUInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick DBus LinguistTools)
find_package(KF6Config REQUIRED)
find_package(KF6WindowSystem REQUIRED)

add_executable(lingmo-welcome
    src/main.cpp
    src/welcome.cpp
    resources.qrc
)

target_link_libraries(lingmo-welcome PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::DBus
    KF6::ConfigCore KF6::WindowSystem
)

set(TRANSLATIONS_DIR ${CMAKE_INSTALL_FULL_DATADIR}/lingmo-welcome/translations)
target_compile_definitions(lingmo-welcome PRIVATE
    TRANSLATIONS_DIR="${TRANSLATIONS_DIR}"
    LINGMO_WELCOME_VERSION="${PROJECT_VERSION}"
)
# lrelease only: building never rewrites the .ts sources
qt_add_translation(QM_FILES translations/lingmo-welcome_pt_BR.ts)
add_custom_target(translations ALL DEPENDS ${QM_FILES})
install(FILES ${QM_FILES} DESTINATION ${TRANSLATIONS_DIR})

install(TARGETS lingmo-welcome RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES lingmo-welcome.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES icons/lingmo-welcome.png DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps)
# First login only: `--first-run` exits at once when the tour was already seen
install(FILES lingmo-welcome-autostart.desktop
        DESTINATION ${CMAKE_INSTALL_FULL_SYSCONFDIR}/xdg/autostart
        RENAME lingmo-welcome.desktop)
