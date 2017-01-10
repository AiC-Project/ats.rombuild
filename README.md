
Building Android Images for AiC
===============================

This repository automates the creation of AOSP images for the AiC project.

Requirements:

 - A lot of disk space and time. 90-100GB for each Android version is a reasonable assumption.
 - A reasonably modern linux distribution (tested with Ubuntu 16.10).
 - The commands `make` and `docker`.


Install bin/repo
----------------

Repo is a Google tool used to handle many git repositories in a sane way.

```
user@server:~/aic/ats.rombuild$ make bin/repo
curl -s https://storage.googleapis.com/git-repo-downloads/repo -o bin/repo && chmod 755 bin/repo
```

Download the AOSP mirror (optional)
-----------------------------------

If you need to build multiple AOSP versions (for instance, Android 4.4.4 and 5.1.1) you should make
a local mirror of all AOSP repositories.

When a local mirror is available, recreating the sources of any version is faster and consumes a lot less bandwidth.

Downloading too much data from android.googlesource.com can trigger a temporary ban on your IP address.

The downside is that the mirror takes about 125GB and contains more than a thousand repositories.

To create the local mirror, run

```
user@server:~/aic/ats.rombuild$ ./bin/mirror-update
repo mirror has been initialized in /home/user/aic/ats.rombuild/src/mirror
Fetching projects:   0% (1/1125)
[...]
Fetching projects: 100% (1125/1125), done.
```

After the first download, you can periodically run mirror-update to synchronize with the upstream sources.


Download the sources
--------------------

If you have a local mirror, run:

```
user@server:~/aic/ats.rombuildtest$ make rom-init-mirror
mkdir -p src/aic-kitkat && cd src/aic-kitkat && /home/user/aic/ats.rombuildtest/bin/repo init -q
-u https://github.com/AiC-Project/manifest.git -b aic-kitkat --reference=/home/user/aic/ats.rombuildtest/src/mirror
warning: no common commits
[...]

repo has been initialized in /home/user/aic/ats.rombuildtest/src/aic-kitkat
mkdir -p src/aic-lollipop && cd src/aic-lollipop && /home/user/aic/ats.rombuildtest/bin/repo init -q
-u https://github.com/AiC-Project/manifest.git -b aic-lollipop --reference=/home/user/aic/ats.rombuildtest/src/mirror
[...]
```

If you decided NOT to have a local mirror, run `make rom-init-nomirror` instead.

Then create the source tree:

```
user@server:~/aic/ats.rombuildtest$ make rom-sync-all
/home/user/aic/ats.rombuildtest/bin/rom-sync src/aic-kitkat
Fetching projects: 100% (378/378), done.
Syncing work tree: 100% (377/377), done.

/home/user/aic/ats.rombuild/bin/rom-sync src/aic-lollipop
Fetching projects: 100% (388/388), done.
Syncing work tree: 100% (387/387), done.
```

The above command creates a directory under `src/` for each available branch.
You can adapt the `Makefile` to your needs, for instance to only download a specific branch.

Even after syncing, do NOT remove src/mirror as that would break the existing source trees.


Compiling Android
-----------------

The following command requires access to docker, therefore you may need to run it through sudo.

It creates docker images with compiler + dependencies, then run the compilation inside containers
that share the sources through a volume.


```
user@server:~/aic/ats.rombuild$ sudo make rom-build-all
docker build --build-arg USER_ID=1000 --build-arg GROUP_ID=1000 -t aic.rombuilder-4.4.4 docker/4.4.4
Sending build context to Docker daemon 4.608 kB
Step 1 : FROM ubuntu:16.04
 ---> 2fa927b5cdd3
Step 2 : ENV archive "make-3.82.tar.gz"
 ---> Running in f0eb3ed0a0be
[...]
I/diskutils(29143): Wrote 1073741824 bytes to out/target/product/gobyt/android_system_disk.img @ 31365120
Updated inst_boot length to be 5413KB
Updated inst_system length to be 1048576KB
Copying images to specified partition offsets
File edit complete. Wrote 2 images.
Done with bootable android system-disk image -[ out/target/product/gobyt/android_system_disk.img ]-
WARNING: The character device /dev/vboxdrv does not exist.
         Please install the virtualbox-dkms package and the appropriate
         headers, most likely linux-headers-generic.

         You will not be able to start VMs until this problem is fixed.
Converting from raw image file="out/target/product/gobyt/android_system_disk.img" to file="out/target/product/gobyt/android_system_disk.vdi"...
Creating dynamic image with size 1105106944 bytes (1054MB)...
Done with VirtualBox bootable system-disk image -[ out/target/product/gobyt/android_system_disk.vdi ]-
```

For each compiled branch, two images will appear under `./android/{branch-name}/{gobyp, gobyt}/` as soon as they are built,
respectively for phone and tablet.

You can reference these directories directly from the other AiC deployment scripts, or pack everything with `make android-images.tar`.


Compile the kernel (Kitkat only):
---------------------------------

In AOSP 5.x and later, the kernel is compiled with the rest of the system.

To do the same for kitkat, you'll have to compile it manually before running `make rom-build-all`.

You don't need to do that unless you want to change configuration, because the aic-kitkat
sources include a precompiled kernel image.

```
$ git clone https://github.com/AiC-Project/kernel.git -b aic-kitkat src/kernel
$ cp src/aic-kitkat/device/aicVM/blob/bzImage.config src/kernel/.config
$ . bin/kernel-env.sh
$ cd src/kernel
$ make clean oldconfig

(optional) make xconfig

$ make -j4
$ cp arch/x86/boot/bzImage ../aic-kitkat/device/aicVM/blob/
$ cp drivers/video/uvesafb.ko ../aic-kitkat/device/aicVM/blob/
$ cp .config ../aic-kitkat/device/aicVM/blob/
```

