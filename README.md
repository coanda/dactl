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

### Configuration

Instructions for configuring dactl can be found at
https://dactl.readthedocs.org/en/latest/setup.html.

Note: The documentation also include installation instructions which are out of date. Use the instructions given below instead.

## Docker build

```sh
// base image
docker build --build-arg pc_token=<some-packagecloud-token> -t dactl-debian -f docker/Dockerfile .

// post install image
docker build --build-arg pc_token=<some-packagecloud-token> -t dactl-debian-post -f docker/Dockerfile-post .

// test install image
docker build -t dactl-debian-test-install -f docker/Dockerfile-test-apt-install .
```

### Installation

## Fedora 30 (from source)

```bash
sudo dnf update
sudo dnf install -y git                         \
                    meson                       \
                    ninja-build                 \
                    gnome-common                \
                    intltool                    \
                    gcc                         \
                    vala                        \
                    libgee-devel                \
                    json-glib-devel             \
                    gsl-devel                   \
                    libxml2-devel               \
                    libmatheval-devel           \
                    comedilib-devel             \
                    libpeas-devel               \
                    libsoup-devel               \
                    gtksourceview-devel         \
                    librsvg2-devel              \
                    webkit2gtk3-devel

export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/
sudo ninja -C _build install
echo "/usr/local/lib64" | sudo tee --append /etc/ld.so.conf
sudo ldconfig
```

## Debian 10 (from source)

```bash
# Install dependencies
sudo apt install  -y git                        \
                     meson                      \
                     gcc                        \
                     valac                      \
                     libpeas-dev                \
                     libsoup2.4-dev             \
                     libgtksourceview-3.0-dev   \
                     librsvg2-dev               \
                     libwebkit2gtk-4.0-dev      \
                     gettext

export PKG_CONFIG_PATH=/usr/local/lib/x86_64-linux-gnu/pkgconfig/
git clone git@github.com:coanda/dactl.git
cd dactl
meson _build
sudo ninja -C _build install
echo "/usr/local/lib/x86_64-linux-gnu" | sudo tee --append /etc/ld.so.conf
sudo ldconfig
```

### Debian 10 (packagecloud)

Alternatively, it can be installed as a Debian package which is hosted on packagecloud.

```bash
# from packagecloud

sudo apt update
sudo apt install --no-install-recommends -qq -y curl ca-certificates
sudo curl -s https://packagecloud.io/install/repositories/coanda/public/script.deb.sh | sudo bash

# just dactl
sudo apt install dactl

# libdactl
sudo apt install -y libdactl-1.0

# devlopment
sudo apt install -y libdactl-1.0-dev
```
