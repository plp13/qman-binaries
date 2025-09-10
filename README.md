# qman-binaries
A set of tools for building fully static Linux binary packages for
[Qman](https://github.com/plp13/qman)

These packages have no dependencies and, in principle, can be used on any Linux
distribution. For the time being, they are for `x86_64` only.

## Dependencies

The following are required:
- A modern Linux distribution with `bash`, the standard utilities and
  development tools, `python`, and `git`
- All the required
  [dependencies](https://github.com/plp13/qman/blob/main/doc/BUILDING.md#dependencies)
  for building Qman
- `dpkg-deb` for building the `.deb` package
- `rpmbuild` for building the `.rpm` package

Because we are building statically linked binaries, a Linux distribution that
provides static `.a` libraries is also required.

For Arch linux (a distribution that does not provide such libraries) we provide
the [arch-packages/rebuild_all.sh](arch-packages/rebuild_all.sh) script. It can
be used as follows:

```
$ cd arch-packages/
$ ./rebuild_all.sh
```

The script will rebuild and reinstall all Arch Linux packages that are necessary
for building Qman with static library support enabled. It requires `sudo`
privileges, and will prompt you to install the rebuilt packages.

`rebuild_all.sh` accepts the following optional command-line argument:
- `-h` - show help

## Building the packages

The [build/build.sh](build/build.sh) script can be used to build the binary
packages as follows:

```
$ cd build/
$ ./build.sh <branch or tag>
```

Any branch (e.g. `main`, `devel`) or tag (e.g. `v1.6.0`) can be specified,
provided it supports static linking (i.e. the `staticexe` `meson` option).

> **:bulb: Note**
>
> Currently, the only branch that supports this is `devel`. The first stable
> version to support static linking will be 1.6.0.

`build.sh` configures `meson` with the following options:

```
-Dtests=disabled -Dstaticexe=true
```

Additional options can be passed via the `BUILD_MESON_OPTIONS` environment
variable. For example, to enable `libbsd` support, use:

```
$ BUILD_MESON_OPTIONS="-Dlibbsd=enabled" ./build.sh devel
```

The following package types are created:
- `qman-<version>.x86-64.tar.gz` - generic tarball
- `qman_<version>_amd64.deb` - package for distributions that use `.deb`, such
  as Debian and Ubuntu
- `qman-version`x86_64.rpm - package for distributions that use `.rpm`, such as
  Fedora, RHEL, Rocky Linux, and AlmaLinux

`build.sh` also accepts the following optional command-line arguments:
- `-c` - clean up the build directory
- `-g` - only build the generic package
- `-d` - only build the generic and `.deb` packages
- `-r` - only build the generic and `.rpm` packages
- `-h` - show help

## Problems

This solution is still under heavy development, so there should be many. Please
open [issues](https://github.com/plp13/qman-binaries/issues).
