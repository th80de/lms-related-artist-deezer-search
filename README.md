# Deezer-Suche für ähnliche Künstler

Ein eigenständiges Plugin für Lyrion/Logitech Media Server (LMS). Es ergänzt
den Menüpunkt **Ähnliche Künstler** des Plugins **Music and Artist
Information** um eine Deezer-Interpretensuche.

## Verhalten

Beim Öffnen eines ähnlichen Künstlers wird das vorhandene Menü unverändert
übernommen und ergänzt um:

- **Deezer: Interpret suchen** – ruft im bereits eingerichteten Deezer-Plugin
  eine strikte Interpretensuche mit dem angeklickten Namen auf.
- **Lokale Bibliothek durchsuchen** – der vorhandene MAI-"Browse"-Eintrag;
  er startet die LMS-Suche nach demselben Künstlernamen.

Bandcamp, BBC Sounds und weitere Einträge anderer Plugins werden weder entfernt
noch verändert.

## Voraussetzungen

- LMS 8.3 oder neuer
- aktiviertes Plugin [Music and Artist Information](https://github.com/michaelherger/MusicArtistInfo)
- aktiviertes und mit Deezer angemeldetes [Deezer-Plugin](https://github.com/philippe44/lms-deezer)

Das Plugin verwendet keine Deezer-Zugangsdaten und enthält keine Einstellungen.

## Installation

1. Lade die Datei `RelatedArtistDeezerSearch-<version>.zip` aus den GitHub
   Releases herunter bzw. füge die URL zu `repo.xml` unter **Einstellungen →
   Plugins → Zusätzliche Repositories** hinzu.
2. Aktiviere „Deezer-Suche für ähnliche Künstler“ und starte LMS neu, falls
   LMS dazu auffordert.
3. Öffne in Material Skin einen ähnlichen Künstler. „Deezer: Interpret suchen“
   und „Lokale Bibliothek durchsuchen“ müssen sichtbar sein.

## Release erstellen

`./scripts/release.sh` erzeugt unter `dist/` ein versioniertes ZIP und die
SHA-1-Summe. Aktualisiere bei einer neuen Version die URL und Summe in
`repo.xml`, dann veröffentliche das ZIP als GitHub Release. Versioniere den
ZIP-Dateinamen bei jedem Release neu, damit LMS keine alte Datei aus seinem
Cache verwendet.

## Kompatibilität

Music and Artist Information stellt für dieses Untermenü keinen öffentlichen
Erweiterungshook bereit. Das Plugin umschließt daher ausschließlich dessen
`getArtistMenu`-Methode nach dem LMS-Start. Fehlt eine benötigte Methode oder
ist eines der beiden Plugins deaktiviert, wird nichts verändert und LMS bleibt
nutzbar. Nach einem Update von MAI sollte der manuelle Smoke-Test unten
wiederholt werden.

## Manueller Smoke-Test

1. Wähle in Material Skin einen bekannten ähnlichen Künstler mit Sonderzeichen
   (zum Beispiel „Björk“).
2. Prüfe, dass Deezer die Interpreten-Suche mit genau diesem Namen öffnet.
3. Prüfe die lokale Suche und die weiterhin verfügbaren externen Einträge.
4. Deaktiviere testweise Deezer oder MAI und starte LMS neu: Es darf kein
   fehlerhaftes Künstler-Menü entstehen.

## Tests

Auf einem Entwicklerrechner genügt:

```sh
prove -I. t
```
