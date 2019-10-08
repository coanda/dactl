.. _setup:

============
Installation
============

Requirements
============

* Linux is the only tested OS
* GNOME 3 is the only tested DE
* Vala

Building from Source
====================

The source code is hosted on `GitHub <https://github.com/coanda/dactl.git>`_.

Pre-installation Setup
----------------------

Install Fedora 19 .. 23 dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: none
   :linenos:

   sudo dnf install -y automake autoconf libtool gnome-common intltool gcc vala
   sudo dnf install -y glib2-devel gtk3-devel libxml2-devel libgee-devel \
    json-glib-devel clutter-devel clutter-gtk-devel gsl-devel gtksourceview3-devel \
    libmatheval-devel sqlite-devel gobject-introspection-devel gettext-devel \
    gettext-common-devel libmodbus-devel comedilib-devel librsvg2-devel \
    python3-devel pygobject3-devel libpeas-devel libsoup-devel webkitgtk4-devel

Install Ubuntu 14.04 dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Notice: These commands have only been tested as part of a Travis-CI build.

.. code-block:: none
   :linenos:

   sudo add-apt-repository ppa:vala-team/ppa -y
   sudo apt-get update -qq
   sudo apt-get install -qq gnome-common libglib2.0-dev libjson-glib-dev \
    libgee-0.8-dev libvala-0.22-dev libgsl0-dev libsqlite0-dev libxml2-dev \
    libmatheval-dev libmodbus-dev libcomedi-dev valac-0.22 librsvg2-dev \
    libgirepository1.0-dev libgtk-3-dev libclutter-1.0-dev libclutter-gtk-1.0-dev \
    python3-dev python-gobject-dev

Compiled Dependencies
---------------------

Install Vala dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: none
   :linenos:

   git clone https://github.com/geoffjay/modbus-vapi.git
   git clone https://github.com/geoffjay/comedi-vapi.git
   sudo mkdir -p /usr/local/lib/pkgconfig
   sudo cp comedi-vapi/comedi.pc /usr/local/lib/pkgconfig/
   ver=`vala --version | sed -e 's/.*\([0-9]\.[0-9][0-9]\).*/\1/'`
   sudo cp comedi-vapi/comedi.vapi /usr/share/vala-$ver/vapi/
   sudo cp modbus-vapi/libmodbus.vapi /usr/share/vala-$ver/vapi/

Install libcld
^^^^^^^^^^^^^^

.. code-block:: none
   :linenos:

   git clone https://github.com/geoffjay/libcld.git
   cd libcld
   git checkout ca85cde6f53632bcf6b298cd10f336e31f071f2c
   export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
   ./autogen.sh
   make && sudo make install
   cd ..
   echo "/usr/local/lib" | sudo tee --append /etc/ld.so.conf
   sudo ldconfig

Compile and Install dactl
-------------------------

.. warning::
   Installation overwrites the configuration file at `$(sysconfdir)/dactl/`, if an
   alternate value wasn't provided for `--prefix` than this is probably
   `/usr/local/etc/dactl`. It's recommended that the existing configuration is copied
   over `data/config/dactl.xml` or backed up and dealt with separately.

.. code-block:: none
   :linenos:

   git clone https://github.com/coanda/dactl.git
   cd dactl
   git checkout v0.3.x-hotfix
   export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
   ./autogen.sh
   sudo cp vapi/glib-extra.vapi /usr/share/vala-0.32/vapi/
   make && sudo make install

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
