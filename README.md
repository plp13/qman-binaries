# qman-binaries
A set of tools for building fully static Linux binary packages for Qman

These packages have no dependencies and, in principle, can be used on any Linux
distribution. For the time being, they are for `x86_64` only.

## HOWTO

A Linux distribution that provides static `.a` libraries is required.

For Arch linux (a distribution that does not provide such libraries) we provide
[arch-packages/rebuild_all.sh](arch-packages/rebuild_all.sh). Simply do the
following:

```
$ cd arch-packages/
$ ./rebuild_all.sh
```

The script will rebuild and reinstall all Arch Linux packages that are necessary
for building Qman with static library support enabled. It requires `sudo` and
will prompt you to install the rebuilt packages.

[dist/build.sh](dist/build.sh) is the script that builds the actual binary
packages. You can use it as follows:

```
$ cd dist/
$ ./build.sh devel
```

`devel` can be replaced with the name of any other Qman branch or tag that
supports static linking.

> **:bulb: Note**
>
> No such branches or tags currently exist. The first Qman version to support
> static linking will be 1.6.0.

The following package types are created:
- `qman-<version>.tar.gz` - generic tarball

## Problems

There should be many. This is an early release. Please open
[issues](https://github.com/plp13/qman-binaries/issues).
