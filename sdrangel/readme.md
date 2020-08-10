<h1>Building and running SDRangel in a Docker container</h1>

[![Docker Pulls](https://img.shields.io/docker/pulls/f4exb06/sdrangelsrv)](https://hub.docker.com/repository/docker/f4exb06/sdrangelsrv)

<h2>Introduction</h2>

Docker 18.09 or later is required. A single Dockerfile is used to build all images thanks to the BuildKit feature of Docker build.

For GUI operation the `xhost` command should be available in the system. This is available in almost distributions as either the `xhost` package or with `xhost` in the package name. e.g `xhost` in Ubuntu, `xorg-xhost` in Arch.

In order to be able to access the USB hardware on the host the udev rules must be properly set for your user (or system wide) on the host. The `udev-rules` folder contains these rules and a script to install them to be run with `sudo install.sh`.

Because SDRangel uses OpenGL this can make it possibly more difficult to run it properly on some hosts and operating systems.  In any case it is assumed that the rendering takes place on the hardware of the host running Docker. For example running with a NVidia graphics card will require to build and run a `linux_nvidia` version of the base image.

As an indication it takes ~36mn to build the `vanilla` image on a laptop with core i7-5700HQ at 2.7 GHz. Note that this also depends on the speed of your network connection as many packages are being downloaded from the Ubuntu archive and also repositories cloned from Github.

<h2>Images</h2>

When building images it is important that the image is built by the user that will also start the container. This is because the UID of the user on the host and the container should match.

<h3>GUI with no specific hardware dependencies</h3>

  - Use the `build_vanilla.sh` script to produce the `sdrangel/vanilla:latest` image. `latest` is the default but can be user defined with `-t` option. You would normally use the SDRangel version
  - Use the `run.sh` script with options `-g -f vanilla` or just `-g` to run the image

<h3>GUI with a NVidia graphics card</h3>

  - Use the `build_linux_nvidia.sh` script to produce the `sdrangel/nvidia:latest` image. `latest` is the default but can be user defined with `-t` option.
  - Use the `run.sh` script with options `-g -f nvidia` to run the image

As a prerequisite you have to download the driver appropriate to your system:

  - First find out the driver currently in use in your system:
    - `glewinfo | grep Running` to make sure the NVidia card is active (on multi GPU systems)
    - `glxinfo | grep -i nvidia`. It should display a line like `OpenGL core profile version string: 4.6.0 NVIDIA 410.104`. In this example the version is `410.104`.
  - Download the driver installer corresponding to this version from [this archive](https://www.nvidia.com/object/linux-amd64-display-archive.html)
  - Copy it to `NVIDIA-DRIVER.run` in the `sdrangel` folder of the cloned repository (this folder).

Alternatively you can get the driver directly knowing its version. Example:

  - cd to `sdrangel-docker\sdrangel`
  - `wget http://us.download.nvidia.com/XFree86/Linux-x86_64/440.100/NVIDIA-Linux-x86_64-440.100.run`
  - then `cp NVIDIA-Linux-x86_64-440.100.run NVIDIA-DRIVER.run`

<h3>Server with 16 bit Rx samples</h3>

  - Use the `build_server.sh` script to produce the `sdrangel/server16:latest` image. `latest` is the default but can be user defined with `-t` option.
  - Use the `run.sh` script with options `-f server16` to run the image

<h3>Server with 24 bit Rx samples</h3>

  - Use the `build_server.sh -s 24` script to produce the `sdrangel/server24:latest` image. `latest` is the default but can be user defined with `-t` option.
  - Use the `run.sh` script with options `-f server24` to run the image

<h2>Options of the build commands</h2>

<h3>Common options</h3>

The build commands can control from which branch you are cloning the source of SDRangel. You can also give a different tag version than the default.

  - `-b` specifies which branch you are checking out in the clone (default is `master`). The image name of the image tag (after the /) will be the branch name e.g. `sdrangel/dev:linux_nvidia`
  - `-c` specifies an arbitrary commit label. This is to force a fresh clone of the SDRangel repository. If that label changes from the one previously used then the clone layer in the build cache is refreshed.
    - By default this is the current timestamp so each time the build is run a new cache is built
    - You can specify the commit SHA1 so that a fresh copy will be taken only if a new commit took place
  - `-t` specifies the tag version image (default `latest`). You would normally use a tag relative to the git repository for example the tag name for tagged commits or the commit hash.
  - `-j` specifies the number of CPU cores used in the make commands (same as the -j option of make). Default is the number of CPU cores available.

<h3>Build server specific options</h3>

In addition the `build_server.sh` lets you specify the number of Rx bits. The image tag version is suffixed by the number of bits e.g. `server16`

  - `-x` tells to use 24 bit samples for Rx (default is 16)
  - `-f` specify an alternate Dockerfile to the default `Dockerfile` used for `x86-64` architecture. This can be `armv8.ubuntu.Dockerfile` for `armv8` or `arch64` ARM architectures (ex: RPi3 or 4). `armv8.alpine.Dockerfile` is experimental and has issues compiling LimeSuite. To build an ARM image from a x86-64 system you need to install the qemu-user-static package on Ubuntu host, or equivalent.

<h2>Options of the run.sh command</h2>

  - `-g` run a GUI flavor (use with `-f vanilla` (default) or `-f nvidia`). Without this option it is expected to run a server flavor (`-f server16`or `-f server24`)
  - `-f` image flavor. Can be any of:
    - `vanilla`: default. Non specific GUI flavor
    - `nvidia`: GUI flavor specific to Nvidia graphics cards
    - `server16`: Server flavor with 16 bits sample size (I or Q) for the Rx samples
    - `server24`: Server flavor with 24 bits sample size for he Rx samples (effectively 32 bits)
  - `-t` image tag. This is normally the SDRangel version number but is effectively the Docker image tag (what appears after the colon `:` in the `docker images` command output)
  - `-c` container name. Use this to give the container a name. By default this is `sdrangel`
  - `-w` FFTW wisdom file name in the `~/.config/sdrangel` directory. By default this is `fftw-wisdom`

You may specify extra options for port mapping between the host and the container:

  - `-a` specifies the host port linked to the SDRangel REST API port
  - `-u` specifies an UDP port on the host linked to the same port in the container.
  You may have several of these. UDP port mapping is used for Remote Input plugin operation

To speed up FFT plan allocations you can put a FFTW wisdom file in the `~/.config/sdrangel` directory. The `fftwisdom` image in the `fftwisdom` section can be used to produce a compatible FFTW wisdom file. The name of the file can be specified with the `-w` option (see above).

<h3>Examples</h3>

  - `./run.sh -g -c sdrangel -u 9090:9090` starts `sdrangel/vanilla:latest`
  - `./run.sh -g -c sdrangel -u 9090:9090 -w fftw-wisdom-k4` starts `sdrangel/vanilla:latest` using `~/.config/sdrangel/fftw-wisdom-k4` FFTW wisdom file
  - `./run.sh -g -f nvidia -t v4.10.4 -c sdrangel -u 9090:9090` starts `sdrangel/nvidia:v4.10.4`
  - `./run.sh -f server16 -t 38df0a6 -c sdrangel -u 9090:9090` starts `sdrangel/server16:38df0a6`

<h2>Notes about running images</h2>

When the program terminates it will drop to a shell in the container. This leaves the user with the opportunity to inspect the container from inside (ssh connection is also available) or restart the program with the `restart.sh` script found in the home directory of the `sdr` user (default location).

To speed up starting time you have to create a so called FFT Wisdom file. This is critical for small armv8 machines lile the Raspberry-Pi. The typical command to execute is: `fftwf-wisdom -v -n -o ~/.config/sdrangel/fftw-wisdom 128 256 512 1024 2048 4096 b128 b256 b512 b1024 b2048 b4096`

If you intend to use audio you have to install `pulseaudio`on the host and restart it. This is needed even if you are planning to use only remote audio via UDP.
