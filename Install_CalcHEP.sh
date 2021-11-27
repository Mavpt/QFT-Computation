#!/bin/sh

# ----- Variables -----
PACKAGE='CalcHEP'
PACKAGENAME='calchep'
PACKAGEVER='3.8.10'
WEBSITE='https://theory.sinp.msu.ru/~pukhov/calchep.html'

SRCDIR="$HOME/.local/src/$PACKAGE"
BINDIR="$HOME/.local/bin"
WORKDIR="$PWD/CalcHEP"

#ARCHIVE='calchep_3.8.10.tgz'
ARCHIVE="$PACKAGENAME""_$PACKAGEVER.tgz"
DOWLOADLINK="https://theory.sinp.msu.ru/~pukhov/CALCHEP/$ARCHIVE"

BIN='mkWORKdir'
BINF="$BINDIR/CalcHEP-mkWORKdir"

# ----- Introduction -----
echo "This script installs $PACKAGE $PACKAGEVER in GNU/Linux operating systems."
echo "For more info go to $WEBSITE"

# ----- System Info + make -----
echo '1/8 : Getting system info'
if [ -f /etc/os-release ]; then # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then # Older Debian/Ubuntu/etc.
    OS='Debian'
    VER=$(cat /etc/debian_version)
else # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo '2/10 : Checking if make and curl are available'
if [ "$(command -v make 2>&1 /dev/null)" ] & [ "$(command -v curl 2>&1 /dev/null)" ]; then
        printf '\tmake and curl are available\n'
elif [ "$OS" = 'Arch Linux' ]; then
        printf '\tmake and/or curl was not detected, attempting to install it with pacman\n'
        sudo pacman -Syu make curl
elif [ "$OS" = 'Ubuntu' ] && [ "$VER" = '20.04' ]; then
        printf '\tmake and/or curl was not detected, attempting to install it with apt\n'
        sudo apt update && sudo apt upgrade && sudo apt install make curl
else
        printf '\tmake and/or curl was not detected\n\tPlease have both installed before proceeding'
        exit 1
fi

# ----- Make Directories -----
echo '2/8 : Making necessary directories'
mkdir --parents "$SRCDIR" "$BINDIR"
cd "$SRCDIR" || exit 1

# ----- Update PATH -----
echo "3/8 : Updating PATH to include $BINDIR (only works if using $HOME/.bashrc)"
echo "export PATH=\"\$PATH:$BINDIR\"" >> "$HOME/.bashrc"
export PATH="$PATH:$BINDIR"

# ----- Download -----
echo "4/8 : Downloading $PACKAGE $PACKAGEVER from $DOWLOADLINK"
[ -f "$ARCHIVE" ] || curl --silent --user anonymous:anonymous "$DOWLOADLINK" --output "$ARCHIVE"

# ----- Unpack tgz -----
echo "5/8 : Unpacking $ARCHIVE."
tar xzf "$ARCHIVE"
cd "${ARCHIVE%.*}" || exit 1

# ----- Compile and Move -----
echo "6/8 : Compiling"
make

echo "7/8 : Moving $BIN to $BINF"
cp "$BIN" "$BINF"

# ----- Test -----
echo "8/8 : Create working directory $WORKDIR"
"$BINF" "$WORKDIR"
