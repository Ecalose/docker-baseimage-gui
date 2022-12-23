#!/bin/sh
#
# Helper script that builds OpenBox as a static binary.
#
# NOTE: This script is expected to be run under Alpine Linux.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define software versions.
OPENBOX_VERSION=3.6.1
PANGO_VERSION=1.49.3
LIBXRANDR_VERSION=1.5.3

# Define software download URLs.
OPENBOX_URL=http://openbox.org/dist/openbox/openbox-${OPENBOX_VERSION}.tar.xz
PANGO_URL=https://download.gnome.org/sources/pango/${PANGO_VERSION%.*}/pango-${PANGO_VERSION}.tar.xz
LIBXRANDR_URL=https://www.x.org/releases/individual/lib/libXrandr-${LIBXRANDR_VERSION}.tar.xz

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--as-needed --static -static -Wl,--strip-all"

export CC=xx-clang-wrapper
export CXX=xx-clang++

function log {
    echo ">>> $*"
}

#
# Install required packages.
#
log "Installing required Alpine packages..."
apk --no-cache add \
    curl \
    build-base \
    clang \
    meson \
    pkgconfig \
    patch \
    glib-dev \

xx-apk --no-cache --no-scripts add \
    g++ \
    glib-dev \
    glib-static \
    fribidi-dev \
    fribidi-static \
    harfbuzz-dev \
    harfbuzz-static \
    cairo-dev \
    cairo-static \
    libxft-dev \
    libxml2-dev \
    libx11-dev \
    libx11-static \
    libxcb-static \
    libxdmcp-dev \
    libxau-dev \
    freetype-static \
    expat-static \
    libpng-dev \
    libpng-static \
    zlib-static \
    bzip2-static \
    pcre-dev \
    libxrender-dev \
    graphite2-static \
    libffi-dev \
    xz-dev \
    brotli-static \

# Copy the xx-clang wrapper.  OpenBox compilation uses libtool.  During the link
# phase, libtool re-orders all arguments from LDFLAGS.  Thus, libraries are no
# longer between the -Wl,--start-group and -Wl,--end-group arguments.  The
# wrapper detects this scenario and fixes arguments.
cp "$SCRIPT_DIR"/xx-clang-wrapper /usr/bin/

# Create the meson cross compile file.
echo "[binaries]
pkgconfig = '$(xx-info)-pkg-config'

[properties]
sys_root = '$(xx-info sysroot)'
pkg_config_libdir = '$(xx-info sysroot)/usr/lib/pkgconfig'

[host_machine]
system = 'linux'
cpu_family = '$(xx-info arch)'
cpu = '$(xx-info arch)'
endian = 'little'
" > /tmp/meson-cross.txt

#
# Build pango.
# The static library is not provided by Alpine repository, so we need to build
# it ourself.
#
mkdir /tmp/pango
log "Downloading pango..."
curl -# -L ${PANGO_URL} | tar -xJ --strip 1 -C /tmp/pango

log "Configuring pango..."
(
    cd /tmp/pango && LDFLAGS= abuild-meson \
        -Ddefault_library=static \
        -Dintrospection=disabled \
        -Dgtk_doc=false \
        --cross-file /tmp/meson-cross.txt \
        build \
)

log "Compiling pango..."
meson compile -C /tmp/pango/build

log "Installing pango..."
DESTDIR=$(xx-info sysroot) meson install --no-rebuild -C /tmp/pango/build

#
# Build libXrandr.
# The static library is not provided by Alpine repository, so we need to build
# it ourself.
#
mkdir /tmp/libxrandr
log "Downloading libXrandr..."
curl -# -L ${LIBXRANDR_URL} | tar -xJ --strip 1 -C /tmp/libxrandr

log "Configuring libXrandr..."
(
    cd /tmp/libxrandr && LDFLAGS= ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
        --disable-shared \
        --enable-static \
        --enable-malloc0returnsnull \
)

log "Compiling libXrandr..."
make -C /tmp/libxrandr -j$(nproc)

log "Installing libXrandr..."
make DESTDIR=$(xx-info sysroot) -C /tmp/libxrandr install

#
# Build fontconfig.
#
# Fontconfig is already built by an earlier stage in Dockerfile.  The static
# library will be used by OpenBox.  We need to compile our own version to adjust
# different paths used by fontconfig.
# Note that the fontconfig cache generated by fc-cache is architecture
# dependent.  Thus, we won't generate one, but it's not a problem since
# we have very few fonts installed.
#

log "Installing fontconfig..."
cp -av /tmp/fontconfig-install/usr $(xx-info sysroot)

#
# Build OpenBox.
#
mkdir /tmp/openbox
log "Downloading OpenBox..."
curl -# -L ${OPENBOX_URL} | tar -xJ --strip 1 -C /tmp/openbox

log "Patching OpenBox..."
patch -p1 -d /tmp/openbox < "$SCRIPT_DIR"/disable-x-locale.patch
patch -p1 -d /tmp/openbox < "$SCRIPT_DIR"/menu-file-order.patch

# The config.sub provided with OpenBox is too old.  Get a recent one from
# https://github.com/gcc-mirror/gcc/blob/master/config.sub
cp -v "$SCRIPT_DIR"/config.sub /tmp/openbox

log "Configuring OpenBox..."
(
    #cd /tmp/openbox && LIBS="$LDFLAGS" ./configure \

    cd /tmp/openbox && \
        OB_LIBS="-lX11 -lxcb -lXdmcp -lXau -lXext -lXft -lXrandr -lfontconfig -lfreetype -lpng -lXrender -lexpat -lxml2 -lz -lbz2 -llzma -lbrotlidec -lbrotlicommon -lintl -lfribidi -lharfbuzz -lpangoxft-1.0 -lpangoft2-1.0 -lpango-1.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lpcre -lgraphite2 -lffi" \
        LDFLAGS="$LDFLAGS -Wl,--start-group $OB_LIBS -Wl,--end-group" LIBS="$LDFLAGS" ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
        --datarootdir=/opt/base/share \
        --disable-shared \
        --enable-static \
        --disable-nls \
        --disable-startup-notification \
        --disable-xcursor \
        --disable-librsvg \
        --disable-session-management \
        --disable-xkb \
        --disable-xinerama \
)

log "Compiling OpenBox..."
#sed -i 's|--silent|--verbose|' /tmp/openbox/Makefile
make V=1 -C /tmp/openbox -j$(nproc)

log "Installing OpenBox..."
make DESTDIR=/tmp/openbox-install -C /tmp/openbox install
