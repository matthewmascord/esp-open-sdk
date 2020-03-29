esp-open-sdk
------------

This repository provides the integration scripts to build a complete
standalone SDK (with toolchain) for software development with the
Espressif ESP8266 and ESP8266EX chips.

The complete SDK consists of:

1. Xtensa lx106 architecture toolchain (100% OpenSource), based on
   following projects:
    * https://github.com/jcmvbkbc/crosstool-NG
    * https://github.com/jcmvbkbc/gcc-xtensa
    * https://github.com/jcmvbkbc/newlib-xtensa
    * https://github.com/tommie/lx106-hal

The source code above originates from work done directly by Tensilica Inc.,
Cadence Design Systems, Inc, and/or their contractors.

2. ESP8266 IoT SDK from Espressif Systems. This component is only
   partially open source, (some libraries are provided as binary blobs).
    * http://bbs.espressif.com/viewforum.php?f=46

OpenSource components of the SDK are based on:
* lwIP, http://savannah.nongnu.org/projects/lwip/
* Contiki, http://www.contiki-os.org/
* axTLS, http://axtls.sourceforge.net/
* wpa_supplicant, http://w1.fi/wpa_supplicant/ (source withheld by Espressif)
* net80211/ieee80211 (FreeBSD WiFi stack),
  http://www.unix.com/man-page/freebsd/9/NET80211
  (source withheld by Espressif)


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

## MacOS:

This fork incorporates various fixes needed for Mac OS Catalina.

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

## Installing Mac OS pre-requisites:

You will need Homebrew installed first.

The following is a useful one-liner to remove any pre-existing Brew packages. This was
useful to test the below instructions.

```shell script
brew remove --force $(brew list)
```

The following installs all the needed dependencies:

```shell script
brew install \
  binutils \
  coreutils \
  automake \
  wget \ 
  gawk \
  libtool \
  help2man \
  gperf \
  gnu-sed \
  grep \
  ncurses
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

The project can be built in two modes:

1. Where the toolchain and tools are kept separate from the vendor IoT SDK
   which contains binary blobs. This makes licensing more clear, and helps
   facilitate upgrades to vendor SDK releases.

2. A completely standalone ESP8266 SDK with the vendor SDK files merged
   into the toolchain. This mode makes it easier to build software (no
   additinal `-I` and `-L` flags are needed), but redistributability of
   this build is unclear and upgrades to newer vendor IoT SDK releases are
   complicated. This mode is default for local builds. Note that if you
   want to redistribute the binary toolchain built with this mode, you
   should:

    1. Make it clear to your users that the release is bound to a
       particular vendor IoT SDK and provide instructions how to upgrade
       to a newer vendor IoT SDK releases.
    2. Abide by licensing terms of the vendor IoT SDK.

To build the self-contained, standalone toolchain+SDK:

```
$ make STANDALONE=y
```

This is the default choice which most people are looking for, so just the
following is enough:

```
$ make
```

To build the bare Xtensa toolchain and leave ESP8266 SDK separate:

```
$ make STANDALONE=n
```

This will download all necessary components and compile them.

Eventually, you would hope to get a message similar to the below, after 20 minutes or 
so:

```
Xtensa toolchain is built, to use it:

export PATH=/Volumes/case-sensitive/esp-open-sdk/xtensa-lx106-elf/bin:$PATH

Espressif ESP8266 SDK is installed, its libraries and headers are merged with the toolchain
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

ESP8266 SDK will be installed in `sdk/`. If you chose the non-standalone
SDK, run the compiler with the corresponding include and lib dir flags:

```
$ xtensa-lx106-elf-gcc -I$(THISDIR)/sdk/include -L$(THISDIR)/sdk/lib
```

The extra -I and -L flags are not needed when using the standalone SDK.

Subdirectory `examples/` contains some example application(s) which
can be built with esp-open-sdk. If you are interested in real-world,
full-fledged, advanced example of a project built using esp-open-sdk,
check https://github.com/micropython/micropython/tree/master/ports/esp8266.

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

Since version 1.1.0, vendor SDK comes under modified MIT license. Newlib,
used as C library comes with variety of BSD-like licenses. libgcc, compiler
support library, comes with a linking exception. All the above means that
for applications compiled with this toolchain, there are no specific
requirements regarding source availability of the application or toolchain.
(In other words, you can use it to build closed-source applications).
(There're however standard attribution requirements - see licences for
details).
