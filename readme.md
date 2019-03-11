![SDR Angel banner](doc/img/sdrangel_docker.png)

<h1>Running SDRangel in a Docker container</h1>

&#9888; This is still experimental.

[SDRangel](https://github.com/f4exb/sdrangel) is  is an Open Source Qt5 / OpenGL 3.0+ SDR and signal analyzer frontend to various hardware. It also supports remote and terminal (no GUI) operation and can be controlled or control other pieces of software with a REST API.

[SDRangelCli](https://github.com/f4exb/sdrangelcli) is a browser based client application to control SDRangel in remote mode using its REST API.

Eventually Docker compose could be used to fire up the entire SDRangel and SDRangelCli ecosystem.

**Check the discussion group** [here](https://groups.io/g/sdrangel)

<h2>Install Docker</h2>

This is of course the first step. Please check the [Docker related page](https://docs.docker.com/install/) and follow instructions for your distribution.

<h3>Note on Windows</h3>

You can of course install Docker on Windows in two ways:
  - Install with Hyper-V
  - Install with Oracle Virtualbox

But in fact **running SDRangel in a Docker container in Windows is a no-no** in both cases...

In Virtualbox building images is impossible due to network instability. Some apt-get will break at some point.

In Hyper-V there are too many issues with X-Server connection, sound and USB.

<h2>Get familiar with Docker</h2>

Although a set of shell scripts are there to help you build images and run containers it is better to have some understanding on how Docker works and know its most used commands. There are tons of tutorials on the net to get familiar with Docker. Please take time to play with Docker a little bit so that you are proficient enough to know how to build and run images, start containers, etc... Be sure that this is not time wasted just to run this project. Docker is a top notch technology (although based on ancient roots) widely used in the computer industry and at the heart of many IT ecosystems.

<h2>GUI tools</h2>

Optionnally you can install a GUI tool to manage and monitor Docker images and containers.

<h3>Kitematic</h3>

Kitematic is a GUI application to monitor and configure containers live. You can check the [home page here](https://kitematic.com/). Although flagged as "legacy" in Docekr documentation it still alive on Github.

You can check the [Github repository](https://github.com/docker/kitematic) where a .deb package is available. Arch users will find a package in the AUR.

<h3>Portainer</h3>

Kitematic may not be completely functional. Then Portainer can be a good alternative or complement. Moreover Portainer has a richer functionality like showing the subnet to which a container belongs.

Portainer is a web application that is simply started as a container itself. It is started with this Docker command:

`docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer`

Then you simply open a browser page at: [http://localhost:9000](http://localhost:9000). You can use a different port on the host by changing the port mapping in the Docker run command.

Portainer documentation [here](https://portainer.readthedocs.io/en/stable/deployment.html)

<h3>VS code</h3>

Visual Studio Code has a plugin from Microsoft (peterjausovec.vscode-docker) that in addition to Dockerfile syntax highlighting facilitates logging into a container and showing the logs. Click on the whale icon in the left toolbar of VS Code to access these functions.

<h2>SDRangel section</h2>

The files contained in the `sdrangel` directory are used to build and run SDRangel images. Please check the readme inside this folder for further information

<h2>SDRangelCli section</h2>

The files contained in the `sdrangelcli` directory are used to build and run SDRangelCli images. Please check the readme inside this folder for further information

<h2>WSJT-X section</h2>

Due to possible delay in the audio when running SDRangel in a container WSJT-X may fail to decode.

The files contained in the `wsjtx` directory are used to build and run an image where WSJT-X and the `libfaketime` library are compiled. `libfaketime` is used to change system time as WSJT-X sees it.

Note that this is only for your convenience. It is also possible to use `libfaketime` with WSJT-X in the host without impacting the system clock.

<h2>Compose section</h2>

The files contained in the `compose` directory are used to set up and run Docker Compose stacks. Please check the readme inside this folder for further information
