# Data Acquisition and Control Application [![Documentation Status](https://readthedocs.org/projects/dactl/badge/?version=latest)](https://readthedocs.org/projects/dactl/?badge=latest)
[![Build Status](https://travis-ci.org/coanda/dactl.svg)](https://travis-ci.org/coanda/dactl)
[![Issues Status](https://badge.waffle.io/coanda/dactl.png?label=ready&title=Ready)](https://waffle.io/coanda/dactl)

## Description

Dactl is a configurations based application for creating custom data acquisition
and control systems in the GNOME desktop environment.

### Release 0.4

The current public release brings many bug fixes and has separated out as
libraries the core and UI components. These libraries include GIR output for use
in other languages, the support of which is still a work in progress.

### Installation Instructions:

!! These need to be updated !! Use the following instructions for Fedora 27.

Instructions for installing dactl and it's dependencies can be read at
https://dactl.readthedocs.org/en/latest/setup.html.

### Fedora 27 instructions:

## Install Fedora 27 dependencies

```
sudo dnf install -y automake autoconf libtool gnome-common intltool gcc vala
sudo dnf install -y glib2-devel gtk3-devel libxml2-devel libgee-devel \
 json-glib-devel clutter-devel clutter-gtk-devel gsl-devel gtksourceview3-devel \
 libmatheval-devel sqlite-devel gobject-introspection-devel gettext-devel \
 gettext-common-devel libmodbus-devel comedilib-devel librsvg2-devel \
 python3-devel pygobject3-devel libpeas-devel libsoup-devel webkitgtk4-devel
```

## Install vala dependencies

```
git clone https://github.com/geoffjay/modbus-vapi.git
git clone https://github.com/geoffjay/comedi-vapi.git
sudo mkdir -p /usr/local/lib/pkgconfig
sudo cp comedi-vapi/comedi.pc /usr/local/lib/pkgconfig/
ver=`vala --version | sed -e 's/.*\([0-9]\.[0-9][0-9]\).*/\1/'`
sudo cp comedi-vapi/comedi.vapi /usr/share/vala-$ver/vapi/
sudo cp modbus-vapi/libmodbus.vapi /usr/share/vala-$ver/vapi/
```

## Install libcld

```
sudo dnf copr enable geoffjay/libcld
sudo dnf install libcld-devel
```

## Compile and install dactl

```
git clone https://github.com/coanda/dactl.git
cd dactl
sudo mkdir /usr/local/lib64/pkgconfig
sudo mkdir /usr/local/lib/pkgconfig
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/local/lib64/pkgconfig/
meson _build
ninja -C _build
sudo ninja -C _build install
echo "/usr/local/lib" | sudo tee --append /etc/ld.so.conf
echo "/usr/local/lib64" | sudo tee --append /etc/ld.so.conf
sudo ldconfig
```

## Docker build

```sh
// base image
docker build --build-arg pc_token=<some-packagecloud-token> -t dactl-debian -f docker/Dockerfile .

// post install image
docker build --build-arg pc_token=<some-packagecloud-token> -t dactl-debian-post -f docker/Dockerfile-post .

// test install image
docker build -t dactl-debian-test-install -f docker/Dockerfile-test-apt-install .
```

