.. _setup:

============
Installation
============

Requirements
============

* Linux is the only tested OS
* GNOME 3 is the only tested DE
* Vala

Install from PackageCloud
==========================

.. code-block:: none
   :linenos:

   sudo apt update
   sudo apt install --no-install-recommends -qq -y curl ca-certificates
   sudo curl -s https://packagecloud.io/install/repositories/coanda/public/script.deb.sh | sudo bash

   # just dactl
   sudo apt install dactl

   # libdactl
   sudo apt install -y libdactl-1.0

   # devlopment
   sudo apt install -y libdactl-1.0-dev

Building from Source
====================

The source code is hosted on `GitHub <https://github.com/coanda/dactl.git>`_.
The api documentation is hosted on `GitHub <https://coanda.github.io>`_.

Install Fedora 30
-------------------------------

.. code-block:: none
   :linenos:

   sudo dnf update
   sudo dnf install -y git                       \
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

Install Debian 10
------------------------------

.. code-block:: none
   :linenos:

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

.. warning::
   Installation overwrites the configuration file at `$(sysconfdir)/dactl/`, if an
   alternate value wasn't provided for `--prefix` than this is probably
   `/usr/local/etc/dactl`. It's recommended that the existing configuration is copied
   over `data/config/dactl.xml` or backed up and dealt with separately.

Post-installation Configuration
-------------------------------

The make install command given previously will overwrite the site-wide configuration,
to fix the ownership settings you may need to do something along the lines:

.. code-block:: none
   :linenos:

   chown -R `whoami`.$(id -gn `whoami`) /usr/local/etc/dactl
   chmod -R g+w /usr/local/etc/dactl
   chmod +x /usr/local/share/applications/dactl.desktop

Optional but Useful
-------------------

Currently the only drivers tested for data acquisition hardware are comedi. You
might be able to do something in dactl without comedi, but probably not. Some
distributions (Ubuntu?) have support for comedi built into the kernel provided,
but not Fedora. The instructions that we use for compiling comedi using dkms are

.. code-block:: none
   :linenos:

   su -
   dnf install -y automake autoconf libtool git dkms kernel-devel kernel-headers
   git clone git://comedi.org/git/comedi/comedi.git
   cp -R comedi/ /usr/src/comedi-0.7.76+20120626git-1.nodist
   cd /usr/src/
   dkms add -m comedi -v 0.7.76+20120626git-1.nodist
   cd comedi-0.7.76+20120626git-1.nodist && ./autogen.sh && cd ..
   dkms build -m comedi -v 0.7.76+20120626git-1.nodist
   dkms install -m comedi -v 0.7.76+20120626git-1.nodist
   echo "KERNEL==\"comedi*\", MODE=\"0666\", GROUP=\"iocard\"" > /etc/udev/rules.d/95-comedi.rules

After these steps if you have a comedi compatible device you should be able to
`modprobe comedi` as well as that for the device and it should show up in `/dev`.
If not, a test device can be created by:

.. code-block:: none
   :linenos:

   su -
   dnf install -y comedilib comedilib-devel
   modprobe comedi comedi_num_legacy_minors=4
   modprobe comedi_test
   comedi_config /dev/comedi0 comedi_test

However, test devices are of limited use, they allow for instructions only on
with no support [#f1]_ for commands.

.. rubric:: Footnotes

.. [#f1]

   At least not that I'm aware of.
