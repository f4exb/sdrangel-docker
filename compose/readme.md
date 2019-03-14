<h1>Running SDRangel ecosystem with Docker Compose</h1>

<h2>Introduction</h2>

Docker Compose lets you "compose" Docker containers that is start many containers in their own subnet so that they can communicate together in isolation. It is a general recommendation to dedicate one container per functionnality so typically one would use compose to start one container for SDRangel application (GUI or server) and another container for the SDRangelCli web client. You can of course do this manually but Docker Compose offers the convenience to start all containers automatically.

First you will have to install Docker Compose in your system. Follow instructions [here](https://docs.docker.com/compose/install/)

Then take the time to run the [small example](https://docs.docker.com/compose/gettingstarted/) to check your installation and get a bit familiar with docker-compose.

<h2>Building images</h2>

It is assumed that the various images for SDRAngel and SDRAngelCli have been built from the corresponding directories.

<h2>Getting the log</h2>

Kitematic or Portainer GUIs can show the log but only partially. To get a larger part of the log or the complete log you will have to use the `docker logs` command.

First get the container id:
<pre><code>docker ps -a
CONTAINER ID        IMAGE                      COMMAND             CREATED             STATUS              PORTS                                                                   NAMES
482ddf88673f        sdrangel/bionic:server16   "/start.sh"         22 minutes ago      Up 21 minutes       0.0.0.0:8091->8091/tcp, 0.0.0.0:9094->9094/udp, 0.0.0.0:50022->22/tcp   sdrangel_1
da8731da1272        sdrangelcli/node:latest    "http-server"       22 minutes ago      Up 22 minutes       0.0.0.0:8080->8080/tcp                                                  sdrangelcli_1
5ba81852ed59        portainer/portainer        "/portainer"        5 hours ago         Up 5 hours          0.0.0.0:9000->9000/tcp                                                  confident_beaver
</code></pre>

Then using the container id you can fetch the log. You can use the `--since` parameter to select the starting point. This can be relative thus to get the full log just give a large enough value:

<pre><code>docker logs --since 30m 482ddf88673f > sdrangel.log</code></pre>

<h2>SDRangel and SDRangelCli composition</h2>

The `run.sh` script sets up a composition with a SDRangel and a SDRangelCli instance that can be used to remotely control the former. It takes the following arguments:

  - `-g`: starts the GUI variant of SDRangel else the server variant will be started.
  - `-b` specifies the branch used when compiling SDRangel and that appears in the image name (default is `master`)
  - `-t version`: GUI only: SDRangel image name version (ex: `vanilla`). This is mandatory.
  - `-r bits`: Server only: number of Rx bits. This makes up the version suffix (ex: `16` makes `server16`). Default is `16`.
  - `-n suffix`: gives a suffix to the container names (default is `1`). The container names are `sdrangel_{suffix}` for SDRangel and `sdrangelcli_{suffix}` for SDRangelCli.
  - `-w port`: host port for the web client interface (SDRangelCli). Default is `8080`.
  - `-s port`: host port to access the SDRangel container SSH server. Default is `50022`.
  - `-a port`: host port for the SDRangel REST API. Default is `8091`.
  - `-u port[-port]`: maps a UDP port or a range of ports from host to the SDRangel container (same). Default is `9090`.
