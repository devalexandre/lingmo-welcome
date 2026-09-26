/*
 * Copyright (C) 2026 LingmoOS Team.
 *
 * Author:     devalexandre <alexandre@dev2learn.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QCommandLineParser>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QGuiApplication>
#include <QIcon>
#include <QLocale>
#include <QSettings>
#include <QStandardPaths>
#include <QTimer>
#include <QTranslator>

#include <memory>

#include "welcome.h"

static const QString DBusService = QStringLiteral("com.lingmo.Welcome");
static const QString DBusPath = QStringLiteral("/Welcome");

// The Lingmo platform theme doesn't always hand the icon theme over at startup:
// use the one set in Lingmo Settings.
static void applyIconTheme()
{
    const QString current = QIcon::themeName();
    if (!current.isEmpty() && current != QLatin1String("hicolor"))
        return;
    QSettings theme(QStringLiteral("lingmoos"), QStringLiteral("theme"));
    const bool dark = theme.value(QStringLiteral("DarkMode"), false).toBool();
    const QStringList candidates = {
        theme.value(dark ? QStringLiteral("DarkIconTheme") : QStringLiteral("IconTheme")).toString(),
        dark ? QStringLiteral("Crule-dark") : QStringLiteral("Crule"),
        QStringLiteral("breeze"),
    };
    for (const QString &name : candidates) {
        if (!name.isEmpty()
            && !QStandardPaths::locate(QStandardPaths::GenericDataLocation,
                                       QStringLiteral("icons/%1/index.theme").arg(name)).isEmpty()) {
            QIcon::setThemeName(name);
            break;
        }
    }
    QIcon::setFallbackThemeName(QStringLiteral("hicolor"));
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("lingmo-welcome"));
    app.setApplicationVersion(QStringLiteral(LINGMO_WELCOME_VERSION));
    app.setDesktopFileName(QStringLiteral("lingmo-welcome"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Lingmo welcome tour"));
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption firstRun(QStringLiteral("first-run"),
                                QStringLiteral("Session autostart: show only if the tour wasn't completed yet"));
    parser.addOption(firstRun);
    parser.process(app);

    if (parser.isSet(firstRun) && Welcome::firstRunDone())
        return 0;

    // One instance per session: launching it again brings the window up
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.registerService(DBusService)) {
        if (!parser.isSet(firstRun)) {
            QDBusInterface iface(DBusService, DBusPath, DBusService, bus);
            iface.call(QStringLiteral("show"));
        }
        return 0;
    }

    applyIconTheme();
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("lingmo-welcome"),
                                       QIcon::fromTheme(QStringLiteral("preferences-desktop"))));

    // Installed location first, then next to the binary (staged/relocated installs)
    QTranslator translator;
    for (const QString &dir : {QStringLiteral(TRANSLATIONS_DIR),
                               app.applicationDirPath() + QStringLiteral("/../share/lingmo-welcome/translations")}) {
        if (translator.load(QLocale(), QStringLiteral("lingmo-welcome"), QStringLiteral("_"), dir)) {
            app.installTranslator(&translator);
            break;
        }
    }

    // At login give the desktop (settings daemon, dock, wallpaper) a moment to come up
    std::unique_ptr<Welcome> welcome;
    QTimer::singleShot(parser.isSet(firstRun) ? 2500 : 0, &app, [&welcome]() {
        welcome = std::make_unique<Welcome>();
        QDBusConnection::sessionBus().registerObject(DBusPath, welcome.get(), QDBusConnection::ExportAllSlots);
        welcome->show();
    });

    const int ret = app.exec();
    // The QML engine must go while the application still exists
    welcome.reset();
    return ret;
}
