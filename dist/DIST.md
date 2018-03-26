# Dactl Distribution

## RPM

### Building

This assumes an existing `rpmbuild` created through the standard ways.

```sh
ver=`grep Version dist/dactl.spec | sed 's/^.*:\s*//'`
rpkg -C /etc/rpkg.conf srpm --outdir ~/rpmbuild/SOURCES --spec dist/dactl.spec
mv v$ver.tar.gz ~/rpmbuild/SOURCES/
rpmbuild -bb dist/dactl.spec
```

### Installing

```sh
sudo dnf install -y ~/rpmbuild/RPMS/x86_64/dactl-$ver-1.$dist.x86_64.rpm
```

## Flatpak

_TODO_

## Snap

_TODO_
