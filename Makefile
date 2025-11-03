# Makefile for simreader

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LDFLAGS = -lpcsclite
INCLUDES = -I/usr/include/PCSC

SRCDIR = src
MANDIR = man
DOCDIR = doc
BUILDDIR = build
PREFIX = /usr/local

TARGET = $(BUILDDIR)/simreader
SOURCE = $(SRCDIR)/simreader.c
MANPAGE = $(MANDIR)/simreader.1

# Default target
all: $(TARGET)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Build the main binary
$(TARGET): $(SOURCE) | $(BUILDDIR)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

# Debug build
debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)

# Install binary and man page
install: $(TARGET)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/simreader
	install -d $(DESTDIR)$(PREFIX)/share/man/man1
	install -m 644 $(MANPAGE) $(DESTDIR)$(PREFIX)/share/man/man1/simreader.1
	install -d $(DESTDIR)$(PREFIX)/share/doc/simreader
	install -m 644 README.md LICENSE $(DESTDIR)$(PREFIX)/share/doc/simreader/

# Uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/simreader
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/simreader.1
	rm -rf $(DESTDIR)$(PREFIX)/share/doc/simreader

# Clean build artifacts
clean:
	rm -rf $(BUILDDIR)

# Test build
test: $(TARGET)
	$(TARGET) --version
	$(TARGET) --help

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install -y libpcsclite-dev libccid pcscd

# Install dependencies (Fedora/CentOS)
install-deps-fedora:
	sudo dnf install -y pcsc-lite-devel pcsc-lite-ccid pcsc-lite

# Install dependencies (Arch Linux)
install-deps-arch:
	sudo pacman -S pcsclite ccid

# Static analysis
lint:
	cppcheck --enable=all --std=c99 $(SOURCE)

# Format code
format:
	clang-format -i $(SOURCE)

# Package for AUR
aur-pkg: $(TARGET)
	@echo "Creating AUR package..."
	makepkg -f

# Help target
help:
	@echo "Available targets:"
	@echo "  all       - Build simreader (default)"
	@echo "  debug     - Build with debug symbols"
	@echo "  install   - Install to system"
	@echo "  uninstall - Remove from system"
	@echo "  clean     - Clean build artifacts"
	@echo "  test      - Build and test"
	@echo "  aur-pkg   - Create AUR package"
	@echo "  install-deps - Install dependencies (Ubuntu/Debian)"
	@echo "  install-deps-fedora - Install dependencies (Fedora/CentOS)"
	@echo "  install-deps-arch - Install dependencies (Arch Linux)"
	@echo "  lint      - Run static analysis"
	@echo "  format    - Format code"
	@echo "  help      - Show this help"

.PHONY: all debug install uninstall clean test aur-pkg install-deps install-deps-fedora install-deps-arch lint format help