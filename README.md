esp-open-sdk
------------

This repository provides the integration scripts to build the
 Xtensa lx106 architecture toolchain (100% OpenSource) for software 
 development with the Espressif ESP8266 and ESP8266EX chips.

This is based on the following projects:
 * https://github.com/jcmvbkbc/crosstool-NG
 * https://github.com/jcmvbkbc/gcc-xtensa
 * https://github.com/jcmvbkbc/newlib-xtensa
 * https://github.com/tommie/lx106-hal

The source code above originates from work done directly by Tensilica Inc.,
Cadence Design Systems, Inc, and/or their contractors.

This fork builds just the toolchain excluding the SDK and incorporates fixes 
needed for Mac OS Catalina.

1. Sed fixes due to Mac sed used in preference go GNU Sed - fix by adding gnubin
path before /usr/bin (see below)

1. crosstool-NG/configure.ac in the linked submodule is tweaked to allow Bash versions greater than 3. Not actually
a Mac-specific issue but could be if you have purposefully installed Bash 4 or above.
    
    Line 193 changed to:
    
    ```
                         |$EGREP '^GNU bash, version (3\.[1-9]|[4-9])')
    ```

1. Fixes derived from https://github.com/pfalcon/esp-open-sdk/issues/342#issuecomment-449662238

    On line 51-52 of crosstool-NG/kconfig/Makefile,
    
    ```makefile
    $(nconf_OBJ) $(nconf_DEP): CFLAGS += $(INTL_CFLAGS) -I/usr/local/Cellar/ncurses/6.2/include
    nconf: LDFLAGS += -lmenu -lpanel $(LIBS) -L/usr/local/Cellar/ncurses/6.2/lib
    ```

Requirements and Dependencies
=============================

To build the standalone SDK and toolchain, you need a GNU/POSIX system
(Linux, BSD, MacOSX, Windows with Cygwin) with the standard GNU development
tools installed: bash, gcc, binutils, flex, bison, etc.

Please make sure that the machine you use to build the toolchain has at least
1G free RAM+swap (or more, which will speed up the build).

## Debian/Ubuntu

Ubuntu 14.04:
```
$ sudo apt-get install make unrar-free autoconf automake libtool gcc g++ gperf \
    flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial \
    sed git unzip bash help2man wget bzip2
```

Later Debian/Ubuntu versions may require:
```
$ sudo apt-get install libtool-bin
```

## Installing Mac OS pre-requisites:

You will need Homebrew installed first.

The following is a useful one-liner to remove any pre-existing Brew packages. This was
useful to test the below instructions.

```shell script
brew remove --force $(brew list)
```

The following installs all the needed dependencies:

```shell script
brew install binutils coreutils automake wget gawk libtool help2man gperf gnu-sed grep ncurses
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH:/usr/local/Cellar/ncurses/6.2/bin:/usr/local/opt/binutils/bin"
```

Double-check your path. The the bintools and ncurses need to be after /usr/bin and /usr/local/bin.
See https://github.com/pfalcon/esp-open-sdk/issues/342#issuecomment-468391431

For example,

```shell script
% echo $PATH
/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/Cellar/ncurses/6.2/bin:/usr/local/opt/binutils/bin
```

Assuming your default file system is not case-sensitive, you will need to
create and mount a case-sensitive drive, and then recursively clone
the repo from this drive.

The easiest way to do this in Mac OS is to create a new case-sensitive APFS volume
using Disk Utility called case-sensitive.  This will appear as /Volumes/case-sensitive and will not
need mounting on every reboot.

Building
========

Be sure to clone recursively:

```shell script
cd /Volumes/case-sensitive
git clone --recursive https://github.com/matthewmascord/esp-open-sdk.git
cd esp-open-sdk
```

To build the toolchain:

```
$ make
```

This will download all necessary components and compile them.

Eventually, you would hope to get a message similar to the below, after 20 minutes or 
so:

```
Xtensa toolchain is built, to use it:

export PATH=/Volumes/case-sensitive/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
```

Using the toolchain
===================

Once you complete build process as described above, the toolchain (with
the Xtensa HAL library) will be available in the `xtensa-lx106-elf/`
subdirectory. Add `xtensa-lx106-elf/bin/` subdirectory to your `PATH`
environment variable to execute `xtensa-lx106-elf-gcc` and other tools.
At the end of build process, the exact command to set PATH correctly
for your case will be output. You may want to save it, as you'll need
the PATH set correctly each time you compile for Xtensa/ESP.

Pulling updates
===============
The project is updated from time to time, to get updates and prepare to
build a new SDK, run:

```
$ make clean
$ git pull
$ git submodule sync
$ git submodule update --init
```

If you don't issue `make clean` (which causes toolchain and SDK to be
rebuilt from scratch on next `make`), you risk getting broken/inconsistent
results.

Additional configuration
========================

You can build a statically linked toolchain by uncommenting
`CT_STATIC_TOOLCHAIN=y` in the file `crosstool-config-overrides`. More
fine-tunable options may be available in that file and/or Makefile.

License
=======

esp-open-sdk is in its nature merely a makefile, and is in public domain.
However, the toolchain this makefile builds consists of many components,
each having its own license. You should study and abide them all.

Quick summary: gcc is under GPL, which means that if you're distributing
a toolchain binary you must be ready to provide complete toolchain sources
on the first request.

