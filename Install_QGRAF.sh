#!/bin/sh

# ----- Variables -----
PACKAGE='QGRAF'
PACKAGENAME='qgraf'
PACKAGEVER='3.5.0'
WEBSITE='http://cfif.ist.utl.pt/~paulo/qgraf.html'

SRCDIR="$HOME/.local/src/$PACKAGE-$PACKAGEVER"
BINDIR="$HOME/.local/bin"

#ARCHIVE='qgraf-3.5.0.tgz'
ARCHIVE="$PACKAGENAME-$PACKAGEVER.tgz"
DOWLOADLINK="http://qgraf.tecnico.ulisboa.pt/v3.5/$ARCHIVE"
SHA256='09228905ffa8e6b7d07d1c17b6e20c91a16d3d66193de5271b868d759deb175a'

SRC="${ARCHIVE%.*}.f08"

BIN="$PACKAGENAME"
BINF="$BINDIR/$PACKAGENAME"

# ----- Introduction -----
echo "This script installs $PACKAGE $PACKAGEVER in GNU/Linux operating systems."
echo "For more info go to $WEBSITE"

# ----- System Info + gfortran -----
echo '1/10 : Getting system info'
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

echo '2/10 : Checking if gfortran and curl are available'
if [ "$(command -v gfortran 2>&1 /dev/null)" ] & [ "$(command -v curl 2>&1 /dev/null)" ]; then
        printf '\tgfortran and curl are available\n'
elif [ "$OS" = 'Arch Linux' ]; then
        printf '\tgfortran and/or curl was not detected, attempting to install it with pacman\n'
        sudo pacman -Syu gfortran curl
elif [ "$OS" = 'Ubuntu' ] && [ "$VER" = '20.04' ]; then
        printf '\tgfortran and/or curl was not detected, attempting to install it with apt\n'
        sudo apt update && sudo apt upgrade && sudo apt install gfortran curl
else
        printf '\tgfortran and/or curl was not detected\n\tPlease have both installed before proceeding'
        exit 1
fi

# ----- Make Directories -----
echo '3/10 : Making necessary directories'
mkdir --parents "$SRCDIR" "$BINDIR"
cd "$SRCDIR" || exit 1

# ----- Update PATH -----
echo "4/10 : Updating PATH to include $BINDIR (only works if using $HOME/.bashrc)"
echo "export PATH=\"\$PATH:$BINDIR\"" >> "$HOME/.bashrc"
export PATH="$PATH:$BINDIR"

# ----- Download -----
echo "5/10 : Downloading $PACKAGE $PACKAGEVER from $DOWLOADLINK"
[ -f "$ARCHIVE" ] || curl --silent --user anonymous:anonymous "$DOWLOADLINK" --output "$ARCHIVE"

echo '6/10 : Checking if download was successful10'
SHA256D=$(sha256sum "$ARCHIVE" | awk -F ' ' '{print $1}')
if [ "$SHA256" != "$SHA256D" ]; then
        printf '\tThe sha256sums do not match (%s and %s)\n\tPlease try again\n' "$SHA256D" "$SHA256"
        rm "$ARCHIVE"
        exit 1
else
        printf '\tDownload was successful\n'
fi

# ----- Unpack tgz -----
echo "7/10 : Unpacking $ARCHIVE."
tar xzf "$ARCHIVE"

# ----- Compile and Move -----
echo "8/10 : Compiling $SRC into $BIN"
gfortran "$SRC" -o "$BIN"

echo "9/10 : Moving $BIN to $BINF"
cp "$BIN" "$BINF"

# ----- Test -----
echo '10/10 : Testing'
sed -e 's/ phi3/phi3/' -i qgraf.dat
"$BINF"
