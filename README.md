# Deezer-Suche für ähnliche Künstler

Ein eigenständiges Plugin für Lyrion/Logitech Media Server (LMS). Es ergänzt
die globale Suche, die Material Skin beim Antippen eines ähnlichen Künstlers
aus **Music and Artist Information** öffnet, um Deezer.

## Verhalten

Material Skin löst für einen ähnlichen Künstler die globale LMS-Suche aus. Die
lokalen Treffer werden dabei sofort eingeblendet; unter **Suche auf ...**
werden zusätzliche Dienste angeboten. Dieses Plugin ergänzt dort **Deezer**
neben Bandcamp und BBC Sounds. Ein Klick darauf startet eine strikte
Deezer-Interpretensuche mit dem unveränderten Künstlernamen.

## Voraussetzungen

- LMS 8.3 oder neuer
- aktiviertes und mit Deezer angemeldetes [Deezer-Plugin](https://github.com/philippe44/lms-deezer)

Das Plugin verwendet keine Deezer-Zugangsdaten und enthält keine Einstellungen.

## Installation

1. Lade die Datei `RelatedArtistDeezerSearch-<version>.zip` aus den GitHub
   Releases herunter bzw. füge die URL zu `repo.xml` unter **Einstellungen →
   Plugins → Zusätzliche Repositories** hinzu.
2. Aktiviere „Deezer-Suche für ähnliche Künstler“ und starte LMS neu, falls
   LMS dazu auffordert.
3. Öffne in Material Skin einen ähnlichen Künstler. Unter **Suche auf ...**
   muss neben Bandcamp und BBC Sounds der Eintrag „Deezer“ erscheinen.

## Release erstellen

`./scripts/release.sh` erzeugt unter `dist/` ein versioniertes ZIP und die
SHA-1-Summe. Aktualisiere bei einer neuen Version die URL und Summe in
`repo.xml`, dann veröffentliche das ZIP als GitHub Release. Versioniere den
ZIP-Dateinamen bei jedem Release neu, damit LMS keine alte Datei aus seinem
Cache verwendet.

## Kompatibilität

Material Skin verwendet für ähnliche Künstler nicht MAIs `getArtistMenu`,
sondern `Slim::Menu::GlobalSearch`. Das Plugin registriert dort einen normalen
Suchanbieter. Fehlt Deezer oder seine Suchmethode, wird nichts registriert und
LMS bleibt nutzbar.

## Manueller Smoke-Test

1. Wähle in Material Skin einen bekannten ähnlichen Künstler mit Sonderzeichen
   (zum Beispiel „Björk“).
2. Prüfe, dass unter „Suche auf ...“ Deezer neben Bandcamp und BBC Sounds
   erscheint und die Interpreten-Suche mit genau diesem Namen öffnet.
3. Prüfe, dass die lokale Sofortsuche unverändert bleibt.
4. Deaktiviere testweise Deezer und starte LMS neu: Es darf kein fehlerhafter
   Suchanbieter entstehen.

## Tests

Auf einem Entwicklerrechner genügt:

```sh
prove -I. t
```
