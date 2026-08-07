# Dungeology -- budowanie TAP-a dla ZX Spectrum 48K.
#
# Asembler uruchamiany jest z katalogu build/, a nie z korzenia repozytorium.
# Nazwa pliku wyjsciowego jest zaszyta w zrodlach (EMPTYTAP "dng.tap"
# w dung.asm oraz SAVETAP w loader.asm), a sjasmplus rozwiazuje `include`
# wzgledem katalogu pliku, ktory je zawiera. Uruchomienie go z build/
# odklada wiec TAP-a w build/, a wszystkie include'y nadal trafiaja do
# defs/ i data/. Zadne zrodlo nie wymaga zmiany.
#
#   make          zbuduj build/dng.tap
#   make run      uruchom go w ZEsarUX jako Spectrum 48K
#   make clean    usun build/
#
# Jesli masz sjasmplusa w PATH, uzywany jest Twoj. Jesli nie, `make` zbuduje
# go sobie sam ze zrodel do .toolchain/ (upstream nie wydaje binarki dla
# Linuksa, a w Homebrew nie ma formuly -- wiec tak samo dziala to lokalnie
# i na runnerach CI).

.PHONY: all clean run toolchain

SJASMPLUS_VERSION := 1.22.0
SJASMPLUS_SHA256  := 438c41765ea097bef3e7acbb3ec56aba4bb3dd2642290261750602e677b158f4
SJASMPLUS_URL := https://github.com/z00m128/sjasmplus/releases/download/v$(SJASMPLUS_VERSION)/sjasmplus-$(SJASMPLUS_VERSION)-src.tar.xz

TOOLCHAIN_DIR := .toolchain
SJASMPLUS_SRC := $(TOOLCHAIN_DIR)/sjasmplus-$(SJASMPLUS_VERSION)
VENDORED_SJASMPLUS := $(SJASMPLUS_SRC)/sjasmplus

# sha256sum na Linuksie, shasum na macOS.
SHA256SUM := $(shell command -v sha256sum >/dev/null 2>&1 \
	&& echo sha256sum || echo shasum -a 256)

SYSTEM_SJASMPLUS := $(shell command -v sjasmplus 2>/dev/null)
ifeq ($(SYSTEM_SJASMPLUS),)
SJASMPLUS := $(abspath $(VENDORED_SJASMPLUS))
SJASMPLUS_DEP := $(VENDORED_SJASMPLUS)
else
SJASMPLUS := $(SYSTEM_SJASMPLUS)
SJASMPLUS_DEP :=
endif

BUILD_DIR := build
TAP := $(BUILD_DIR)/dng.tap
SOURCES := $(wildcard *.asm) $(wildcard defs/*.def) $(wildcard data/*.dat)

# ZEsarUX z PATH, a jesli go tam nie ma -- domyslna sciezka instalacji na
# macOS. Mozna nadpisac:  make run ZESARUX=/sciezka/do/zesarux
ZESARUX ?= $(shell command -v zesarux 2>/dev/null \
	|| echo /Applications/ZEsarUX.app/Contents/MacOS/zesarux)
ZESARUX_MACHINE ?= 48k
ZESARUX_FLAGS ?=

all: $(TAP)

$(TAP): $(SOURCES) $(SJASMPLUS_DEP) | $(BUILD_DIR)
	cd $(BUILD_DIR) && "$(SJASMPLUS)" ../dung.asm

$(BUILD_DIR):
	mkdir -p $@

toolchain: $(VENDORED_SJASMPLUS)

$(VENDORED_SJASMPLUS):
	mkdir -p $(TOOLCHAIN_DIR)
	curl -sSL -o $(TOOLCHAIN_DIR)/sjasmplus-src.tar.xz "$(SJASMPLUS_URL)"
	echo "$(SJASMPLUS_SHA256)  $(TOOLCHAIN_DIR)/sjasmplus-src.tar.xz" \
		| $(SHA256SUM) -c -
	tar xf $(TOOLCHAIN_DIR)/sjasmplus-src.tar.xz -C $(TOOLCHAIN_DIR)
	$(MAKE) -C $(SJASMPLUS_SRC)

run: $(TAP)
	@test -x "$(ZESARUX)" || \
		{ echo "Nie znaleziono ZEsarUX: $(ZESARUX)" >&2; \
		  echo "Podaj sciezke:  make run ZESARUX=/sciezka/do/zesarux" >&2; \
		  exit 1; }
	"$(ZESARUX)" --nosplash --nowelcomemessage --verbose 0 \
		--machine $(ZESARUX_MACHINE) $(ZESARUX_FLAGS) "$(abspath $(TAP))"

clean:
	rm -rf $(BUILD_DIR)
