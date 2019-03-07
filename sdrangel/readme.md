<h1>Building and running SDRangel in a Docker container</h1>

<h2>Introduction</h2>

Docker 18.09 or later is required. A single Dockerfile is used to build all images thanks to the BuildKit feature of Docker build.

Because SDRangel uses OpenGL this can make it possibly more difficult to run it properly on some hosts and operating systems.  In any case it is assumed that the rendering takes place on the hardware of the host running Docker. For example running on a Linux host with a NVidia graphics card will require to build and run a `linux_nvidia` version of the base image.

In Windows with Virtualbox it is possible to use XMing for the X display that seems to be able to run OpenGL apps without hassles. In which case the display variable should be `DISPLAY=10.0.2.2:0`.

<h2>Images</h2>

<h3>GUI with no specific hardware dependencies</h3>

  - Use the `build_vanilla.sh` script to produce the `sdrangel/bionic:vanilla` image
  - Use the `run.sh` script with options `-g -t vanilla` to run the image

<h3>GUI in Linux host with a NVidia graphics card</h3>

  - Use the `build_linux_nvidia.sh` script to produce the `sdrangel/bionic:linux_nvidia` image
  - Use the `run.sh` script with options `-g -t linux_nvidia` to run the image

<h3>Server with 16 bit Rx samples</h3>

  - Use the `build_server16.sh` script to produce the `sdrangel/bionic:server16` image
  - Use the `run.sh` script with options `-t server16` to run the image

<h3>Server with 24 bit Rx samples</h3>

  - Use the `build_server24.sh` script to produce the `sdrangel/bionic:server24` image
  - Use the `run.sh` script with options `-t server24` to run the image

<h2>Additional options to the run.sh command<h3>

You may specify extra options for port mapping between the host and the container:

  - `-s` specifies the host port linked to the container ssh port (22)
  - `-a` specifies the host port linked to the SDRangel REST API port
  - `-u` specifies an UDP port on the host linked to the same port in the container. You may have several of these. UDP port mapping is used for Remote Input plugin operation

<h2>Notes about running images</h2>

When the program terminates it will drop to a shell in the container. This leaves the user with the opportunity to inspect the container from inside (ssh connection is also available) or restart the program.

A SSH connection to the container is always available with user `sdr` and password `sdr`. `sdr` is the user executing the program and it has sudo rights.