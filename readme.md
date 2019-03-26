![SDR Angel banner](doc/img/sdrangel_docker.png)

<h1>Running SDRangel in a Docker container</h1>

&#9888; This is still experimental.

[SDRangel](https://github.com/f4exb/sdrangel) is  is an Open Source Qt5 / OpenGL 3.0+ SDR and signal analyzer frontend to various hardware. It also supports remote and terminal (no GUI) operation and can be controlled or control other pieces of software with a REST API.

[SDRangelCli](https://github.com/f4exb/sdrangelcli) is a browser based client application to control SDRangel in remote mode using its REST API.

Eventually Docker compose could be used to fire up the entire SDRangel and SDRangelCli ecosystem.

**Check the discussion group** [here](https://groups.io/g/sdrangel)

<h2>Install Docker</h2>

This is of course the first step. Please check the [Docker related page](https://docs.docker.com/install/) and follow instructions for your distribution.

<h3>Windows</h3>

You can of course install Docker on Windows in two ways:
  - Install Docker Desktop For Windows with Hyper-V activated
  - Install with Oracle Virtualbox (do not activate Hyper-V)

It turns out that running Docker Desktop For Windows is not an option because you could display something on screen but there are too many issues with X-Server connection, sound and USB.

Thus you will have to run inside a Linux VM in Virtualbox. One important point is to install Virtualbox running the installation program as an administrator else you will not be able to attach USB devices to the virtual machine.

Then things will be the same as when running Docker in a Linux box and thus all the following applies.

<h2>Add your user to the docker group</h2>

**This step is important.** You must <u>not</u> run the various scripts with `sudo` and therefore run docker commands with `sudo`.

In order to run docker commands as a normal user you will need to add your user to the `docker` group (using sudo once): `sudo usermod -a -G docker $USER`. Then you have to log out and back in to make it effective.

Type `groups` to verify `docker` is in the list of groups your user belongs to.

<h2>Get familiar with Docker</h2>

Although a set of shell scripts are there to help you build images and run containers it is better to have some understanding on how Docker works and know its most used commands. There are tons of tutorials on the net to get familiar with Docker. Please take time to play with Docker a little bit so that you are proficient enough to know how to build and run images, start containers, etc... Be sure that this is not time wasted just to run this project. Docker is a top notch technology (although based on ancient roots) widely used in the computer industry and at the heart of many IT ecosystems.

<h2>GUI tools</h2>

Optionnally you can install a GUI tool to manage and monitor Docker images and containers.

<h3>Kitematic</h3>

Kitematic is a GUI application to monitor and configure containers live. You can check the [home page here](https://kitematic.com/). Although flagged as "legacy" in Docekr documentation it still alive on Github.

You can check the [Github repository](https://github.com/docker/kitematic) where a .deb package is available. Arch users will find a package in the AUR.

<h3>Portainer</h3>

Kitematic may not be completely functional. Then Portainer can be a good alternative or complement. Moreover Portainer has a richer functionality like showing the subnet to which a container belongs.

Portainer is a web application that is itself started as a container.

For data persistency you will need to create a volume once with:

`docker volume create portainer_data`

 Then you will start it with this Docker command:

`docker run -d -p 9000:9000 --name portainer --privileged -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer --no-auth -H unix:///var/run/docker.sock`

Then you simply open a browser page at: [http://localhost:9000](http://localhost:9000). You can use a different port on the host by changing the port mapping in the Docker run command.

Portainer documentation [here](https://portainer.readthedocs.io/en/stable/deployment.html)

<h3>VS code</h3>

Visual Studio Code has a plugin from Microsoft (peterjausovec.vscode-docker) that in addition to Dockerfile syntax highlighting facilitates logging into a container and showing the logs. Click on the whale icon in the left toolbar of VS Code to access these functions.

<h2>Getting logs</h2>

The GUI tools can access the log (container stdout and stderr) live but in many cases it is truncated and the start of the log is unavailable. To get a full log you will have to use the Docker CLI commands.

First get a list of containers and spot the container for which you would like to get the log:

<pre><code>docker ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                                                                   NAMES
8075e65626b1        sdrangelcli/node:latest        "http-server"            35 minutes ago      Up 35 minutes       0.0.0.0:8001->8080/tcp                                                  sdrangelcli_1
48ebe711df3e        portainer/portainer            "/portainer --no-auth"   2 days ago          Up 31 minutes       0.0.0.0:9000->9000/tcp                                                  portainer
2e2b2f97dae9        sdrangel/bionic:linux_nvidia   "/start.sh"              2 days ago          Up 8 minutes        0.0.0.0:8091->8091/tcp, 0.0.0.0:9094->9094/udp, 0.0.0.0:50022->22/tcp   sdrangel_1
</code></pre>

Let's say I would like to get the log of the SDRangel instance. It is the container running the `sdrangel/bionic:linux_nvidia` image and has the ID `2e2b2f97dae9`. I see that it has been running since 8 minutes. I will use the `docker log` command that has a `--since` option to tell since when you want to get the log. I can give it any arbitrary value larger than 8 minutes to get the full log:

<pre><code>docker logs --since 10m 2e2b2f97dae9 > ~/sdrangel.log</code></pre>

Or I can pipe it directly into other commands like `less` to browse through it or `grep` to look for something in particular:

<pre></code>docker logs --since 10m 2e2b2f97dae9 | grep -i perseus
2019-03-14 02:33:46.113 (D) PluginManager::loadPluginsDir: fileName:  libinputperseus.so
2019-03-14 02:33:46.113 (I) PluginManager::loadPluginsDir: loaded plugin libinputperseus.so
2019-03-14 02:33:46.117 (D) PluginManager::registerSampleSource  Perseus Input  with source name  sdrangel.samplesource.perseus
2019-03-14 02:33:46.666 (I) DevicePerseusScan::scan: device #0 firmware downloaded
2019-03-14 02:33:46.666 (D) PerseusPlugin::enumSampleSources: enumerated Perseus device #0
</code></pre>

<h2>SDRangel section</h2>

The files contained in the `sdrangel` directory are used to build and run SDRangel images. Please check the [readme](sdrangel/readme.md) inside this folder for further information

<h2>SDRangelCli section</h2>

The files contained in the `sdrangelcli` directory are used to build and run SDRangelCli images. Please check the [readme](sdrangelcli/readme.md) inside this folder for further information

<h2>WSJT-X section</h2>

Due to possible delay in the audio when running SDRangel in a container WSJT-X may fail to decode.

The files contained in the `wsjtx` directory (see [readme](wsjtx/readme.md)) are used to build and run an image where WSJT-X and the `libfaketime` library are compiled. `libfaketime` is used to change system time as WSJT-X sees it.

Note that this is only for your convenience. It is also possible to use `libfaketime` with WSJT-X in the host without impacting the system clock.

<h2>Compose section</h2>

The files contained in the `compose` directory are used to set up and run Docker Compose stacks. Please check the readme inside this folder for further information
