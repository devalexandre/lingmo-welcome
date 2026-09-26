# Lingmo Welcome

A friendly first-login tour for the ArchLingmo desktop. In six short steps it
lets people:

1. **Welcome** — the Lingmo logo over our wallpaper and a *Get started* button.
2. **Appearance** — pick Light or Dark and an accent color (applied live).
3. **Wallpaper** — click one of our wallpapers (ArchLingmo first) to use it.
4. **Effects** — wobbly windows, Magic Lamp when minimizing and the Alt+Tab
   *Flip* switcher. Effects KWin reports as unsupported (no GPU acceleration)
   are shown disabled.
5. **Shortcuts** — a cheat sheet of the most useful keys, with a button to
   *Settings → Shortcuts*.
6. **Done** — links to the Discord, the website and Settings, and a
   *Show at startup* option.

It only uses the mechanisms Lingmo Settings already uses, so everything can be
changed back there: the settings daemon (`com.lingmo.Settings` `/Theme`:
`setDarkMode`, `setAccentColor`, `setBackgroundType`, `setWallpaper`) and
`kwinrc` (`[Plugins] <effect>Enabled`, `[TabBox] LayoutName`) followed by
`org.kde.KWin /KWin reconfigure`.

## When it shows up

- `/etc/xdg/autostart/lingmo-welcome.desktop` (Lingmo sessions only) runs
  `lingmo-welcome --first-run`, which exits right away once the tour was seen.
- Closing the window, *Skip* or *Finish* at any step marks it as seen.
- State lives in `~/.config/lingmoos/welcome.conf`:
  `Completed` and `ShowOnStartup` (the *Show at startup* checkbox, off by
  default). Delete the file to see the tour again at the next login.
- "Welcome" in the launcher opens it at any time. Only one instance runs; it
  is reachable on D-Bus as `com.lingmo.Welcome` (`/Welcome`, method `show`).

## Build

```sh
cmake -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build
DESTDIR=/tmp/stage ninja -C build install
```

Dependencies: Qt 6 (Core, Gui, Qml, Quick, DBus, LinguistTools, Qt5Compat),
KF6 Config and WindowSystem, LingmoUI; at runtime the Lingmo settings daemon
(lingmo-core), KWin and lingmo-settings.

Translations: English source strings, `translations/lingmo-welcome_pt_BR.ts`.
Refresh it with `lupdate src qml -ts translations/lingmo-welcome_pt_BR.ts`
(the build only runs `lrelease`).

The bundled logo in `images/` is the Lingmo OS logo from lingmo-artwork's
`brand/`; when lingmo-artwork installs its brand assets
(`/usr/share/lingmo-artwork/brand/`) those are used instead.

## License

GPL-3.0-or-later.
