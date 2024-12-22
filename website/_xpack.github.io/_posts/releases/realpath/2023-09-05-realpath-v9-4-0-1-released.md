---

title:  xPack GNU realpath v9.4.0-1 released

summary: "Version **9.4.0-1** is a new release; it follows the upstream release."

coreutils_version: "9.4"
coreutils_date: "29 Aug 2023"

version: "9.4.0-1"
npm_subversion: "1"

download_url: https://github.com/xpack-dev-tools/realpath-xpack/releases/tag/v9.4.0-1/

comments: true

date: 2023-09-05 22:39:07 +0300

redirect_to: https://xpack-dev-tools.github.io/realpath-xpack/blog/2023/09/05/realpath-v9-4-0-1-released/

# For Jekyll releases selection.
categories:
  - releases
  - realpath

# For navigation; use scripts/createtag.sh in Jekyll.
tags:
  - releases
  - realpath
  - readlink

---

The [xPack GNU realpath](https://xpack.github.io/realpath/)
is a standalone cross-platform binary distribution of
**GNU realpath**, part of
[GNU Core Utilities](https://www.gnu.org/software/coreutils/).

There are separate binaries for
**macOS** (x64 and arm64)
and **GNU/Linux** (x64, arm64 and arm).

{% include note.html content="The main targets for the GNU/Linux Arm
binaries are the **Raspberry Pi** class devices (armv7l and aarch64;
armv6 is not supported)." %}

## Download

The binary files are available from [GitHub Releases]({{ page.download_url }}).

## Prerequisites

- x64 GNU/Linux: any system with **GLIBC 2.27** or higher
  (like Ubuntu 18 or later, Debian 10 or later, RedHat 8 or later,
  Fedora 29 or later, etc)
- arm64/arm GNU/Linux: any system with **GLIBC 2.27** or higher
  (like Raspberry Pi OS, Ubuntu 18 or later, Debian 10 or later, RedHat 8 or later,
  Fedora 29 or later, etc)
- x64 macOS: 10.13 or later
- arm64 macOS: 11.6 or later

## Install

The full details of installing the **xPack GNU realpath** on various platforms
are presented in the separate [Install]({{ site.baseurl }}/dev-tools/realpath/install/) page.

### Easy install

The easiest way to install GNU realpath is with
[`xpm`]({{ site.baseurl }}/xpm/)
by using the **binary xPack**, available as
[`@xpack-dev-tools/realpath`](https://www.npmjs.com/package/@xpack-dev-tools/realpath)
from the [`npmjs.com`](https://www.npmjs.com) registry.

With the `xpm` tool available, installing
the latest version of the package and adding it as
a development dependency for a project is quite easy:

```sh
cd my-project
xpm init # Add a package.json if not already present

xpm install @xpack-dev-tools/realpath@latest --verbose

ls -l xpacks/.bin
```

To install this specific version, use:

```sh
xpm install @xpack-dev-tools/realpath@{{ page.version }}.{{ page.npm_subversion }} --verbose
```

It is also possible to install Meson Build globally, in the user home folder,
but this requires xPack aware tools to automatically identify them and
manage paths.

```sh
xpm install --global @xpack-dev-tools/realpath@latest --verbose
```

### Uninstall

To remove the links created by xpm in the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/realpath
```

To completely remove the package from the central xPack store:

```sh
xpm uninstall --global @xpack-dev-tools/realpath
```

## Compliance

The xPack GNU realpath generally follows the official
[GNU Core Utilities](https://ftp.gnu.org/gnu/coreutils/) releases.

The current version is based on:

- GNU Core Utilities version {{ page.coreutils_version }}
from {{ page.coreutils_date }}.

## Changes

Compared to the upstream version, there are no functional changes.

## Bug fixes

- none

## Enhancements

- none

## Known problems

- none

## Shared libraries

On all platforms the packages are standalone, and expect only the standard
runtime to be present on the host.

All dependencies that are build as shared libraries are copied locally
in the `libexec` folder (or in the same folder as the executable for Windows).

### `DT_RPATH` and `LD_LIBRARY_PATH`

On GNU/Linux the binaries are adjusted to use a relative path:

```console
$ readelf -d library.so | grep runpath
 0x000000000000001d (RPATH)            Library rpath: [$ORIGIN]
```

In the GNU ld.so search strategy, the `DT_RPATH` has
the highest priority, higher than `LD_LIBRARY_PATH`, so if this later one
is set in the environment, it should not interfere with the xPack binaries.

Please note that previous versions, up to mid-2020, used `DT_RUNPATH`, which
has a priority lower than `LD_LIBRARY_PATH`, and does not tolerate setting
it in the environment.

### `@rpath` and `@loader_path`

Similarly, on macOS, the binaries are adjusted with `install_name_tool` to use a
relative path.

## Documentation

The original documentation is available
[online](https://www.gnu.org/software/coreutils/manual/).

## Build

The binaries for all supported platforms
(Windows, macOS and GNU/Linux) were built using the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/), a set
of build environments based on slightly older distributions, that should be
compatible with most recent systems.

For the prerequisites and more details on the build procedure, please see the
[How to build](https://github.com/xpack-dev-tools/realpath-xpack/blob/xpack/README-BUILD.md) page.

## CI tests

Before publishing, a set of simple tests were performed on an exhaustive
set of platforms. The results are available from:

- [GitHub Actions](https://github.com/xpack-dev-tools/realpath-xpack/actions/)
- [Travis CI](https://app.travis-ci.com/github/xpack-dev-tools/realpath-xpack/builds/)

## Tests

TBD

## Checksums

The SHA-256 hashes for the files are:

```txt
bb98c75dae116989fdf49faeb2953445d6afe932879c55b1071953296774bec3
xpack-realpath-9.4.0-1-darwin-arm64.tar.gz

099cf8b4caf22d5aa785e36a13e4ced0e9806aad76bd8b267ccd3900e69a493a
xpack-realpath-9.4.0-1-darwin-x64.tar.gz

7be2771e405529c5c99efa36c974ea4db063b3bba4ca834c798387d20e503b0e
xpack-realpath-9.4.0-1-linux-arm.tar.gz

f64678647deaf5480235a659083e2612429ef3f6c122ab04cf28400fe31f7dff
xpack-realpath-9.4.0-1-linux-arm64.tar.gz

5385b1b9961526bca098699cd7102fd668af6a4dc40499a7fe8a7a7187da5949
xpack-realpath-9.4.0-1-linux-x64.tar.gz

```

## Deprecation notices

### 32-bit support

Support for 32-bit x86 GNU/Linux and x86 Windows was
dropped in 2022. Support for 32-bit Arm GNU/Linux (armv7l) will be preserved
for a while, due to the large user base of 32-bit Raspberry Pi systems.

### GNU/Linux minimum requirements

Support for RedHat 7 was dropped in 2022 and the
minimum requirement was raised to GLIBC 2.27, available starting
with Ubuntu 18, Debian 10 and RedHat 8.

## Pre-deprecation notice for Ubuntu 18.04

Ubuntu 18.04 LTS _Bionic Beaver_ reached the end of the standard five-year
maintenance window for Long-Term Support (LTS) release on 31 May 2023.

As a courtesy, the xPack GNU/Linux releases will continue to be based on
Ubuntu 18.04 for another year.

From 2025 onwards, the GNU/Linux binaries will be built on **Debian 10**,
(**GLIBC 2.28**), and are also expected to run on RedHat 8.

Users are urged to update their build and test infrastructure to
ensure a smooth transition to the next xPack releases.

## Download analytics

- GitHub [xpack-dev-tools/realpath-xpack](https://github.com/xpack-dev-tools/realpath-xpack/)
  - this release [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/realpath-xpack/v{{ page.version }}/total.svg)](https://github.com/xpack-dev-tools/realpath-xpack/releases/v{{ page.version }}/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/realpath-xpack/total.svg)](https://github.com/xpack-dev-tools/realpath-xpack/releases/)
  - [individual file counters](https://somsubhra.github.io/github-release-stats/?username=xpack-dev-tools&repository=realpath-xpack) (grouped per release)
- npmjs.com [@xpack-dev-tools/realpath](https://www.npmjs.com/package/@xpack-dev-tools/realpath)
  - latest releases [![npm](https://img.shields.io/npm/dw/@xpack-dev-tools/realpath.svg)](https://www.npmjs.com/package/@xpack-dev-tools/realpath/)
  - all @xpack-dev-tools releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/realpath.svg)](https://www.npmjs.com/package/@xpack-dev-tools/realpath/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.
