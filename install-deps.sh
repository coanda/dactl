#!/bin/bash

COMEDIVER="0.7.76+20120626git-1.dist"

# make sure that the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "The script needs to be run as root or using sudo." 1>&2
  exit 1
else
  # get the comedi source
  cd /tmp
  git clone git://comedi.org/git/comedi/comedi.git
  cp -R comedi/ /usr/src/comedi-$COMEDIVER
  cd /usr/src/

  # fix a build issue with 0.7.76
  sed -i "s/\(err\s*(\"\)/\/\/\1/" comedi-$COMEDIVER/comedi/drivers/dt9812.c

  # build and install comedi modules using dkms
  dkms add -m comedi -v $COMEDIVER
  cd comedi-$COMEDIVER && ./autogen.sh && cd ..
  dkms build -m comedi -v $COMEDIVER
  dkms install -m comedi -v $COMEDIVER

  # TODO add a section for including the test devices

  # add a udev rule file for comedi devices
  echo "KERNEL==\"comedi*\", MODE=\"0666\", GROUP=\"iocard\"" > \
    /etc/udev/rules.d/95-comedi.rules
  udevadm control reload

  # add the pkg-config file for comedi
  if [ ! -x /usr/lib/pkgconfig/comedi.pc ]; then
    cp deps/comedi.pc /usr/lib/pkgconfig/
  fi
fi
