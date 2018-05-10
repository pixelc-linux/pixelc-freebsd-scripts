# Pixel C FreeBSD scripts

The tools in our organization attempt to be portable, but there are obstacles
that need to be dealt with on non-Linux systems, such as the installation of
the respective external tools.

Since I use FreeBSD myself, the point of this repo is to help other potential
FreeBSD users keep their build process comfortable. Linux users don't need it,
because the tools all work out of box in there.

## Required external tools

Our script chain requires the following commonly installable tools to work:

- POSIX core utilities and shell (`/bin/sh`)
- `git` - repository management (`pkg install git`)
- `wget` - fetching files (`pkg install wget`)
- `cpio` - creating ramdisk images (in base system)
- `tar` - unpacking third party archives (in base system)
- `ar` - unpacking third party archives (in base system)
- `lz4c` - kernel and initrd image compression (`pkg install liblz4`)
- `perl` - mostly used in shell to decode base64 (`pkg install perl5`)

Additionally, it requires additional tools that are not always available:

- `adb` - working with TWRP recovery (`pkg install android-tools-adb`)
- `fastboot` - flash and boot the images (`pkg install android-tools-fastboot`)
- `mkimage` - create `.fit` images from kernel+DTB (`pkg install u-boot-tools`)
- `mkbootimg` - create unsigned Android boot images (**not available OOTB**)
- `futility` - o sign images `mkbootimg` creates (**not available OOTB**)

To build Linux, some more are necessary:

- `bison` - `pkg install bison`
- `flex` - `pkg install flex`

As you can see, `mkbootimg` and `futility` are the tricky parts. You don't need
either to boot a kernel on the Pixel C, but you need both to create images that
can actually persist on the device.

### Getting mkbootimg (and unpackbootimg)

We have a version that works on FreeBSD in our organization. It is not present
in FreeBSD ports. To obtain it, use the script available here.

```
./get_mkbootimg.sh
```

You will need to install `gmake` (`pkg install gmake`). The tool by default
installs into `~/bin` which is in `PATH` on FreeBSD. Provide a custom prefix
as th efirst argument if you want.

This installs two tools, `mkbootimg` and `unpackbootimg`, the latter doing
the reverse of the former (i.e. turn an image into a `zImage` and a ramdisk).

### Getting futility

This one is a bit harder, because no functional version currently exists for
FreeBSD (not yet patched to compile and work). Fortunately, FreeBSD ships with
a Linux binary compatibility layer. We can therefore use the Linux version of
the tool for the time being. Get it:

```
./get_futility.sh
```

You will need `wget` for this to work. It grabs a package from Fedora 26 -
you don't need `rpm` because `tar` handles it. The installation prefix works
the same as for `mkbootimg`.

If you use HardenedBSD, you will need to disable ASLR for the `futility`
binary as is necessary for all Linux binaries. You also need some Linux
packages from the repository - `linux_base-c7` and `linux-c7-openssl-libs`
and of course the Linux emulation enabled.

By default, this fetches a 64-bit binary for 64-bit systems and a 32-bit
one for 32-bit systems. You can manually pass the arch as a second parameter
to the script (`i386` to install a 32-bit binary on a 64-bit system).

# Getting a GCC toolchain for Linux/Pixel C

You will also need a cross-compiler for the `aarch64-linux-gnu` target. You
can use the `get_cross.sh` script for it, which will download, compile and
install `bc`, `binutils` and `gcc`. Only `binutils` and `gcc` are a part of
the actual cross-compiling toolchain, but GNU `bc` is necessary in the Linux
build system.

```
mkdir $HOME/gcc-linux-cross
./get_cross.sh $HOME/gcc-linux-cross 16
```

The second parameter is the number of `gmake` jobs. The first parameter is the
install prefix and it must exist and be writable.

The toolchain supplied with the FreeBSD base system should be enough to build.
If something fails, you can skip the previous components by setting `SKIP_BC`,
`SKIP_BINUTILS` or `SKIP_GCC`.

# Building the Linux kernel

Building the kernel is the same as on Linux. If you use the Pixel C kernel
scripts, they will automatically take care of overriding `sed` and `make`
for the build with `gsed` and `gmake`. You will need to have the cross-gcc
install prefix in your `PATH`. If you're not using the scripts, then you
will need to make sure calling `sed` during the build calls `gsed`; you
can do that for example by symlinking `gsed` as `sed` into your cross prefix.
