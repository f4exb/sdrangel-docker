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
482ddf88673f        sdrangel/server16:v4.10.4  "/start.sh"         22 minutes ago      Up 21 minutes       0.0.0.0:8091->8091/tcp, 0.0.0.0:9094->9094/udp, 0.0.0.0:50022->22/tcp   sdrangel_1
da8731da1272        sdrangelcli:latest         "http-server"       22 minutes ago      Up 22 minutes       0.0.0.0:8080->8080/tcp                                                  sdrangelcli_1
5ba81852ed59        portainer/portainer        "/portainer"        5 hours ago         Up 5 hours          0.0.0.0:9000->9000/tcp                                                  confident_beaver
</code></pre>

Then using the container id you can fetch the log. You can use the `--since` parameter to select the starting point. This can be relative thus to get the full log just give a large enough value:

<pre><code>docker logs --since 30m 482ddf88673f > sdrangel.log</code></pre>

<h2>SDRangel and SDRangelCli composition</h2>

The `run.sh` script brings up (or down) a compose stack with a SDRangel and a SDRangelCli instance that can be used to remotely control the former. It takes the following arguments:

  - `-D`: use this option to bring down the compose stack (default is to bring up). Use the same `-g` and `-c` options if any that you used to bring up the stack. Other options do not matter.
  - `-g`: starts the GUI variant of SDRangel else the server variant will be started.
  - `-f` specifies the flavor used when compiling SDRangel and that appears in the image name after `sdrangel/` (default is `vanilla`)
  - `-t tag`: SDRangel image name tag (ex: `v4.10.4` default is `latest`).
  - `-T tag`: SDRangelcli image name tag (ex: `v1.1.1` default is `latest`).
  - `-S tag`: SDRangelSpectrum image tag (ex: `v1.0.0` default is `latest`)
  - `-c name` : Give a stack name. Default is `compose`.
  - `-n suffix`: gives a suffix to the container names (default is `1`). The container names are `sdrangel_{suffix}` for SDRangel and `sdrangelcli_{suffix}` for SDRangelCli.
  - `-w port`: host port for the web client interface (SDRangelCli). Default is `8080`.
  - `-s port`: host port for the web spectrum (SDRangelSpectrum) (default 8081).
  - `-a port`: host port for the SDRangel REST API. Default is `8091`.
  - `-u port[-port]`: maps a UDP port or a range of ports from host to the SDRangel container (same). Default is `9090`.
  - `-p port[-port]`: maps a TCP port or a range of ports from host to the SDRangel contaoner (same). Default is `8887`.

The composition default network has a fixed subnet address of `172.18.0.0/16`. A fixed address for SDRangel container is interesting if you use UDP connections thus:
  - SDRangel container will have the `172.18.0.2` IPv4 address
  - SDRangelCli will have  `172.18.0.3`
  - SDRangelSpectrum will have `172.18.0.4`.

To speed up FFT plan allocations you can put a FFTW wisdom file named `fftw-wisdom` in the `~/.config/sdrangel` directory. The `fftwisdom` image in the `fftwisdom` section can be used to produce a compatible FFTW wisdom file.

<h2>Examples</h2>

  - `./run.sh -g` starts `sdrangel/vanilla:latest` and `sdrangelcli:latest`
  - `./run.sh -g -f nvidia -t v4.10.4 -c sdrangel -u 9090:9090` starts `sdrangel/nvidia:v4.10.4` and `sdrangelcli:latest`
  - `./run.sh -f server16 -t 38df0a6 -c sdrangel -u 9090:9090` starts `sdrangel/server16:38df0a6` and `sdrangelcli:latest`
  - `./run.sh -f server16 -t v4.10.4 -T v1.1.1` starts `sdrangel/server16:v4.10.1` and `sdrangelcli:v1.1.1`
