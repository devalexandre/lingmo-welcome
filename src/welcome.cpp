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

#include "welcome.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSettings>
#include <QStandardPaths>

#include <KConfig>
#include <KConfigGroup>
#include <KWindowSystem>
#include <KX11Extras>

#include <optional>

static const QString SettingsService = QStringLiteral("com.lingmo.Settings");
static const QString ThemePath = QStringLiteral("/Theme");
static const QString ThemeInterface = QStringLiteral("com.lingmo.Theme");

// ~/.config/lingmoos/welcome.conf
static QSettings *welcomeSettings()
{
    static QSettings settings(QStringLiteral("lingmoos"), QStringLiteral("welcome"));
    return &settings;
}

static QDBusInterface themeInterface()
{
    return QDBusInterface(SettingsService, ThemePath, ThemeInterface, QDBusConnection::sessionBus());
}

Welcome::Welcome(QObject *parent)
    : QObject(parent)
{
    QDBusInterface theme = themeInterface();
    if (theme.isValid()) {
        m_accentColor = theme.property("accentColor").toInt();
        m_wallpaper = theme.property("wallpaper").toString();
    }

    // Our wallpapers first, then a few of Lingmo's
    const QStringList preferred = {
        QStringLiteral("lingmo-arch-monterey-4k.png"),
        QStringLiteral("archlingmo-light.jpg"),
        QStringLiteral("archlingmo-dark.jpg"),
        QStringLiteral("archmac-light.jpg"),
        QStringLiteral("archmac-dark.jpg"),
        QStringLiteral("lingmo_light.jpg"),
        QStringLiteral("lingmo_dark.jpg"),
        QStringLiteral("mountain1.jpg"),
        QStringLiteral("helium.jpg"),
        QStringLiteral("default.jpg"),
    };
    const QStringList dirs = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation,
                                                       QStringLiteral("backgrounds/lingmoos"),
                                                       QStandardPaths::LocateDirectory);
    for (const QString &name : preferred) {
        for (const QString &dir : dirs) {
            const QString path = dir + QLatin1Char('/') + name;
            if (QFileInfo::exists(path)) {
                m_wallpapers << path;
                // The same file may be installed in more than one data dir
                if (QFileInfo(m_wallpaper).fileName() == name)
                    m_wallpaper = path;
                break;
            }
        }
        if (m_wallpapers.size() == 8)
            break;
    }

    connect(qApp, &QCoreApplication::aboutToQuit, this, &Welcome::markSeen);
}

Welcome::~Welcome()
{
    delete m_engine;
}

bool Welcome::firstRunDone()
{
    QSettings *settings = welcomeSettings();
    return settings->value(QStringLiteral("Completed"), false).toBool()
        && !settings->value(QStringLiteral("ShowOnStartup"), false).toBool();
}

void Welcome::show()
{
    if (!m_engine) {
        m_engine = new QQmlApplicationEngine;
        m_engine->rootContext()->setContextProperty(QStringLiteral("welcome"), this);
        m_engine->load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
        if (m_engine->rootObjects().isEmpty()) {
            qWarning("Failed to load the welcome window");
            // Queued: this may run before the event loop started
            QMetaObject::invokeMethod(qApp, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
            return;
        }
        m_window = qobject_cast<QQuickWindow *>(m_engine->rootObjects().first());
        if (m_window) {
            // Closing the window at any step counts as having seen the tour
            connect(m_window, &QWindow::visibleChanged, this, [](bool visible) {
                if (!visible)
                    QCoreApplication::quit();
            });
        }
    }
    if (!m_window)
        return;

    m_window->show();
    m_window->raise();
    m_window->requestActivate();
    if (KWindowSystem::isPlatformX11())
        KX11Extras::forceActiveWindow(m_window->winId());
}

int Welcome::accentColor() const
{
    return m_accentColor;
}

QStringList Welcome::wallpapers() const
{
    return m_wallpapers;
}

QString Welcome::wallpaper() const
{
    return m_wallpaper;
}

bool Welcome::showOnStartup() const
{
    return welcomeSettings()->value(QStringLiteral("ShowOnStartup"), false).toBool();
}

void Welcome::setShowOnStartup(bool show)
{
    if (show == showOnStartup())
        return;
    welcomeSettings()->setValue(QStringLiteral("ShowOnStartup"), show);
    welcomeSettings()->sync();
    emit showOnStartupChanged();
}

QUrl Welcome::brandLogo(const QString &name) const
{
    // lingmo-artwork's brand assets when installed, else our bundled copy
    for (const QString &candidate : {QStringLiteral("lingmo-artwork/brand/%1.svg").arg(name),
                                     QStringLiteral("lingmo-artwork/brand/%1.png").arg(name),
                                     QStringLiteral("backgrounds/lingmoos/brand/%1.png").arg(name)}) {
        const QString path = QStandardPaths::locate(QStandardPaths::GenericDataLocation, candidate);
        if (!path.isEmpty())
            return QUrl::fromLocalFile(path);
    }
    return QUrl(QStringLiteral("qrc:/images/%1.png").arg(name));
}

QUrl Welcome::logo() const
{
    return brandLogo(QStringLiteral("lingmo-logo"));
}

QUrl Welcome::logoWhite() const
{
    return brandLogo(QStringLiteral("lingmo-logo-white"));
}

QString Welcome::version() const
{
    return QStringLiteral(LINGMO_WELCOME_VERSION);
}

void Welcome::setDarkMode(bool dark)
{
    QDBusInterface theme = themeInterface();
    if (theme.isValid())
        theme.call(QStringLiteral("setDarkMode"), dark);
}

void Welcome::setAccentColor(int index)
{
    QDBusInterface theme = themeInterface();
    if (theme.isValid())
        theme.call(QStringLiteral("setAccentColor"), index);
    if (m_accentColor != index) {
        m_accentColor = index;
        emit accentColorChanged();
    }
}

void Welcome::setWallpaper(const QString &path)
{
    if (path.isEmpty() || path == m_wallpaper)
        return;
    QDBusInterface theme = themeInterface();
    if (theme.isValid()) {
        // 0 = picture (a plain color background would hide it)
        theme.call(QStringLiteral("setBackgroundType"), QVariant::fromValue(0));
        theme.call(QStringLiteral("setWallpaper"), path);
    }
    m_wallpaper = path;
    emit wallpaperChanged();
}

bool Welcome::isEffectSupported(const QString &id)
{
    const auto cached = m_supported.constFind(id);
    if (cached != m_supported.constEnd())
        return *cached;
    // Without KWin to ask (another window manager), let the user try
    bool supported = true;
    QDBusInterface effects(QStringLiteral("org.kde.KWin"), QStringLiteral("/Effects"),
                           QStringLiteral("org.kde.kwin.Effects"));
    if (effects.isValid()) {
        const QDBusReply<bool> reply = effects.call(QStringLiteral("isEffectSupported"), id);
        supported = !reply.isValid() || reply.value();
    }
    m_supported.insert(id, supported);
    return supported;
}

bool Welcome::defaultEnabled(const QString &id) const
{
    // Effects and scripts carry KPlugin.EnabledByDefault in their metadata
    const auto enabledByDefault = [&id](const QString &path, bool checkId) -> std::optional<bool> {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly))
            return std::nullopt;
        const QJsonObject plugin = QJsonDocument::fromJson(file.readAll()).object()
                                       .value(QStringLiteral("KPlugin")).toObject();
        if (checkId && plugin.value(QStringLiteral("Id")).toString() != id)
            return std::nullopt;
        return plugin.value(QStringLiteral("EnabledByDefault")).toBool(false);
    };

    for (const QString &candidate : {QStringLiteral("kwin-x11/builtin-effects/%1.json").arg(id),
                                     QStringLiteral("kwin-x11/effects/%1/metadata.json").arg(id),
                                     QStringLiteral("kwin/effects/%1/metadata.json").arg(id)}) {
        const QString path = QStandardPaths::locate(QStandardPaths::GenericDataLocation, candidate);
        if (!path.isEmpty()) {
            if (const auto value = enabledByDefault(path, false))
                return *value;
        }
    }
    // Packages whose directory isn't named after their id
    for (const QString &base : {QStringLiteral("kwin/effects"), QStringLiteral("kwin-x11/effects")}) {
        const QStringList roots = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, base,
                                                            QStandardPaths::LocateDirectory);
        for (const QString &root : roots) {
            const QStringList packages = QDir(root).entryList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (const QString &package : packages) {
                if (const auto value = enabledByDefault(root + QLatin1Char('/') + package + QStringLiteral("/metadata.json"), true))
                    return *value;
            }
        }
    }
    return false;
}

bool Welcome::isEffectEnabled(const QString &id) const
{
    // The user's kwinrc cascaded over the system ones (/etc/xdg/kwinrc holds Lingmo's defaults)
    const KConfig kwinrc(QStringLiteral("kwinrc"), KConfig::CascadeConfig);
    const KConfigGroup plugins = kwinrc.group(QStringLiteral("Plugins"));
    const QString key = id + QStringLiteral("Enabled");
    if (plugins.hasKey(key))
        return plugins.readEntry(key, false);
    return defaultEnabled(id);
}

void Welcome::setEffects(const QHash<QString, bool> &states)
{
    KConfig kwinrc(QStringLiteral("kwinrc"), KConfig::CascadeConfig);
    KConfigGroup plugins = kwinrc.group(QStringLiteral("Plugins"));
    for (auto it = states.cbegin(); it != states.cend(); ++it)
        plugins.writeEntry(it.key() + QStringLiteral("Enabled"), it.value());
    kwinrc.sync();
    reloadKWin();
    ++m_revision;
    emit effectsChanged();
}

void Welcome::setEffectEnabled(const QString &id, bool enabled)
{
    setEffects({{id, enabled}});
}

void Welcome::setMagicLamp(bool enabled)
{
    setEffects({{QStringLiteral("magiclamp"), enabled}, {QStringLiteral("lingmo_squash"), !enabled}});
}

QString Welcome::switcherLayout() const
{
    const KConfig kwinrc(QStringLiteral("kwinrc"), KConfig::CascadeConfig);
    return kwinrc.group(QStringLiteral("TabBox")).readEntry("LayoutName", QStringLiteral("ling_thumbnail"));
}

void Welcome::setSwitcherLayout(const QString &layout)
{
    if (layout == switcherLayout())
        return;
    KConfig kwinrc(QStringLiteral("kwinrc"), KConfig::CascadeConfig);
    kwinrc.group(QStringLiteral("TabBox")).writeEntry("LayoutName", layout);
    kwinrc.sync();
    reloadKWin();
    ++m_revision;
    emit effectsChanged();
}

int Welcome::revision() const
{
    return m_revision;
}

void Welcome::reloadKWin()
{
    QDBusInterface(QStringLiteral("org.kde.KWin"), QStringLiteral("/KWin"), QStringLiteral("org.kde.KWin"))
        .asyncCall(QStringLiteral("reconfigure"));
}

void Welcome::openUrl(const QString &url)
{
    QDesktopServices::openUrl(QUrl(url));
}

void Welcome::openSettings(const QString &module)
{
    QStringList args;
    if (!module.isEmpty())
        args << QStringLiteral("-m") << module;
    QProcess::startDetached(QStringLiteral("lingmo-settings"), args);
}

void Welcome::markSeen()
{
    QSettings *settings = welcomeSettings();
    if (settings->value(QStringLiteral("Completed"), false).toBool())
        return;
    settings->setValue(QStringLiteral("Completed"), true);
    settings->sync();
}

void Welcome::finish()
{
    markSeen();
    if (m_window)
        m_window->close();
    else
        QCoreApplication::quit();
}
