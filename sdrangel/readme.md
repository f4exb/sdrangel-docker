<h1>Building and running SDRangel in a Docker container</h1>

<h2>Introduction</h2>

Docker 18.09 or later is required. A single Dockerfile is used to build all images thanks to the BuildKit feature of Docker build.

For GUI operation the `xhost` command should be available in the system. This is available in almost distributions as either the `xhost` package or with `xhost` in the package name. e.g `xhost` in Ubuntu, `xorg-xhost` in Arch.

In order to be able to access the USB hardware on the host the udev rules must be properly set for your user (or system wide) on the host. The [udev-rules folder](https://github.com/f4exb/sdrangel/tree/master/udev-rules) in the SDRangel Github repository contains these rules and a script to install them to be run with `sudo install.sh`.

Because SDRangel uses OpenGL this can make it possibly more difficult to run it properly on some hosts and operating systems.  In any case it is assumed that the rendering takes place on the hardware of the host running Docker. For example running with a NVidia graphics card will require to build and run a `linux_nvidia` version of the base image.

As an indication it takes ~36mn to build the `vanilla` image on a laptop with core i7-5700HQ at 2.7 GHz. Note that this also depends on the speed of your network connection as many packages are being downloaded from the Ubuntu archive and also repositories cloned from Github.

<h2>Images</h2>

<h3>GUI with no specific hardware dependencies</h3>

  - Use the `build_vanilla.sh` script to produce the `sdrangel/bionic:vanilla` image
  - Use the `run.sh` script with options `-g -t vanilla` to run the image

<h3>GUI with a NVidia graphics card</h3>

  - Use the `build_linux_nvidia.sh` script to produce the `sdrangel/bionic:linux_nvidia` image
  - Use the `run.sh` script with options `-g -t linux_nvidia` to run the image

<h3>Server with 16 bit Rx samples</h3>

  - Use the `build_server16.sh` script to produce the `sdrangel/bionic:server16` image
  - Use the `run.sh` script with options `-t server16` to run the image

<h3>Server with 24 bit Rx samples</h3>

  - Use the `build_server24.sh` script to produce the `sdrangel/bionic:server24` image
  - Use the `run.sh` script with options `-t server24` to run the image

<h2>Additional options to the run.sh command</h2>

You may specify extra options for port mapping between the host and the container:

  - `-s` specifies the host port linked to the container ssh port (22)
  - `-a` specifies the host port linked to the SDRangel REST API port
  - `-u` specifies an UDP port on the host linked to the same port in the container. You may have several of these. UDP port mapping is used for Remote Input plugin operation

<h2>Notes about running images</h2>

When the program terminates it will drop to a shell in the container. This leaves the user with the opportunity to inspect the container from inside (ssh connection is also available) or restart the program with the `restart.sh` script found in the home directory of the `sdr` user (default location).

A SSH connection to the container is always available with user `sdr` and password `sdr`. `sdr` is the user executing the program and it has sudo rights. You may use the `-s` option of the run script to specify the port to be used on the host side then use the `-p` option to specify this port on the `ssh` command.