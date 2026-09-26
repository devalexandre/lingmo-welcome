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

#pragma once

#include <QHash>
#include <QObject>
#include <QPointer>
#include <QStringList>
#include <QUrl>

class QQmlApplicationEngine;
class QQuickWindow;

// Backend of the welcome tour. Every change goes through the same mechanisms
// Lingmo Settings uses: the settings daemon (com.lingmo.Settings /Theme) for the
// theme and wallpaper, kwinrc [Plugins]/[TabBox] + KWin reconfigure for effects.
// Exposed on D-Bus as com.lingmo.Welcome /Welcome (method `show`).
class Welcome : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.lingmo.Welcome")
    Q_PROPERTY(int accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QStringList wallpapers READ wallpapers CONSTANT)
    Q_PROPERTY(QString wallpaper READ wallpaper NOTIFY wallpaperChanged)
    Q_PROPERTY(QString switcherLayout READ switcherLayout NOTIFY effectsChanged)
    Q_PROPERTY(int revision READ revision NOTIFY effectsChanged)
    Q_PROPERTY(bool showOnStartup READ showOnStartup WRITE setShowOnStartup NOTIFY showOnStartupChanged)
    Q_PROPERTY(QUrl logo READ logo CONSTANT)
    Q_PROPERTY(QUrl logoWhite READ logoWhite CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)

public:
    explicit Welcome(QObject *parent = nullptr);
    ~Welcome() override;

    // True when the tour already ran and the user didn't ask to see it at login
    static bool firstRunDone();

    int accentColor() const;
    QStringList wallpapers() const;
    QString wallpaper() const;
    QString switcherLayout() const;
    int revision() const;
    bool showOnStartup() const;
    void setShowOnStartup(bool show);
    QUrl logo() const;
    QUrl logoWhite() const;
    QString version() const;

    Q_INVOKABLE void setDarkMode(bool dark);
    Q_INVOKABLE void setAccentColor(int index);
    Q_INVOKABLE void setWallpaper(const QString &path);

    Q_INVOKABLE bool isEffectSupported(const QString &id);
    Q_INVOKABLE bool isEffectEnabled(const QString &id) const;
    Q_INVOKABLE void setEffectEnabled(const QString &id, bool enabled);
    // Minimize animation: Magic Lamp, or Lingmo's default squash
    Q_INVOKABLE void setMagicLamp(bool enabled);
    Q_INVOKABLE void setSwitcherLayout(const QString &layout);

    Q_INVOKABLE void openUrl(const QString &url);
    Q_INVOKABLE void openSettings(const QString &module = QString());
    // Marks the tour as seen (closing the window at any step does it too)
    Q_INVOKABLE void markSeen();
    Q_INVOKABLE void finish();

public Q_SLOTS:
    void show();

Q_SIGNALS:
    void accentColorChanged();
    void wallpaperChanged();
    void effectsChanged();
    void showOnStartupChanged();

private:
    void setEffects(const QHash<QString, bool> &states);
    bool defaultEnabled(const QString &id) const;
    void reloadKWin();
    QUrl brandLogo(const QString &name) const;

    QQmlApplicationEngine *m_engine = nullptr;
    QPointer<QQuickWindow> m_window;
    int m_accentColor = 0;
    QString m_wallpaper;
    QStringList m_wallpapers;
    QHash<QString, bool> m_supported;
    int m_revision = 0;
};
