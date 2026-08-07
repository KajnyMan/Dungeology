# Dungeology

[![ci](https://github.com/KajnyMan/Dungeology/actions/workflows/ci.yml/badge.svg)](https://github.com/KajnyMan/Dungeology/actions/workflows/ci.yml)
[![release](https://github.com/KajnyMan/Dungeology/actions/workflows/release.yml/badge.svg)](https://github.com/KajnyMan/Dungeology/actions/workflows/release.yml)

Dungeology to dungeon crawler na ZX Spectrum 48K: widok pierwszoosobowy
rysowany z mapy kafelków, pole widzenia, walka i ekwipunek sklecony
z narzędzi ogrodniczych. Całość napisana w asemblerze Z80, bez żadnego
runtime'u — gotowy TAP ma 5999 bajtów.

**Stan:** w trakcie prac.

## Sterowanie

| Klawisz | Akcja |
| --- | --- |
| `I` | prosto |
| `J` | lewo |
| `L` | prawo |
| `O` | drzwi / szukaj |
| `U` | popchnij / rozmawiaj |
| `K` | podnieś / wejdź |

Nazwy przedmiotów są skracane na ekranie do trzech liter. Pełna lista —
17 broni i 17 zbroi — jest w [`read.me`](read.me).

## Pobieranie

Gotowe TAP-y są w [wydaniach](https://github.com/KajnyMan/Dungeology/releases).

Można też pobrać build z dowolnego commita: wejdź w
[Actions](https://github.com/KajnyMan/Dungeology/actions), otwórz wybrane
uruchomienie i zjedź do sekcji *Artifacts*.

## Budowanie

```sh
make          # zbuduj build/dng.tap
make run      # uruchom w ZEsarUX jako Spectrum 48K
make clean    # usuń build/
```

Potrzebny jest [sjasmplus](https://github.com/z00m128/sjasmplus) 1.22.0.
Jeśli masz go w `PATH`, zostanie użyty. Jeśli nie — `make` zbuduje go sobie
sam ze źródeł do `.toolchain/`, bo upstream nie wydaje binarki dla Linuksa
i nie ma formuły w Homebrew.

Ścieżkę do emulatora można nadpisać:

```sh
make run ZESARUX=/ścieżka/do/zesarux
```

## Wydanie nowej wersji

```sh
git tag -a v1.0.0 -m "opis wydania"
git push origin v1.0.0
```

Reszta dzieje się sama: GitHub zbuduje TAP-a i wystawi go jako wydanie.

## Układ repozytorium

```
dung.asm      punkt wejścia -- to jego podaje się asemblerowi
*.asm         moduły: widok 3D, pole widzenia, ekran, matematyka, klawiatura
defs/         stałe, makra i struktury
data/         mapa, kafelki, sprite'y, komunikaty, zmienne
read.me       notatki: sterowanie i skróty nazw przedmiotów
```

Asembler uruchamiany jest z katalogu `build/`, a nie z korzenia repozytorium.
Nazwa pliku wyjściowego jest zaszyta w źródłach (`EMPTYTAP "dng.tap"`),
a sjasmplus rozwiązuje `include` względem katalogu pliku, który je zawiera —
dzięki temu TAP ląduje w `build/`, a wszystkie `include` nadal trafiają do
`defs/` i `data/`. Żadne źródło nie wymagało zmiany.
