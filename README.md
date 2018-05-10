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
- `futility` - plus Chrome OS developer keys, to sign images `mkbootimg`
  creates (**not available OOTB**)

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
