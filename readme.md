![SDR Angel banner](doc/img/sdrangel_docker.png)

<h1>Running SDRangel in a Docker container</h1>

&#9888; This is still experimental and not guaranteed to work in all environments.

[SDRangel](https://github.com/f4exb/sdrangel) is  is an Open Source Qt5 / OpenGL 3.0+ SDR and signal analyzer frontend to various hardware. It also supports remote and terminal (no GUI) operation and can be controlled or control other pieces of software with a REST API.

[SDRangelCli](https://github.com/f4exb/sdrangelcli) is a browser based client application to control SDRangel in remote mode using its REST API.

Eventually Docker compose could be used to fire up the entire SDRangel and SDRangelCli ecosystem.

**Check the discussion group** [here](https://groups.io/g/sdrangel)

<h2>Install Docker</h2>

This is of course the first step. Please check the [Docker related page](https://docs.docker.com/install/) and follow instructions for your system.

<h3>Windows</h3>

In Windows you have two options:
  - Install with Hyper-V: Hyper-V is a bare-metal type hypervisor where the Windows O/S itself runs in a VM. The catch is that it does not work Windows 10 Home version and requires a special set up. This is required to install _Docker Desktop for Windows_. straigtforward to use.
  - Install with Oracle Virtualbox: Virtualbox is a hosted type hypervisor that sits on the top of the Windows O/S so it puts an extra layer on the stack but is available for more flavors of Windows. In this case you will install Docker in a Linux O/S Virtualbox VM for example Ubuntu 18.04 and therefore you will have to follow Linux instructions.

See [this discussion](https://www.nakivo.com/blog/hyper-v-virtualbox-one-choose-infrastructure/) about the difference between Hyper-V and Virtualbox.

After a little bit of experimentation Hyper-V and Docker Desktop for Windows is not an option for SDRangel as it has too many issues with X-Server connection, sound and USB.

<h2>Get familiar with Docker</h2>

Although a set of shell scripts are there to help you build images and run containers it is better to have some understanding on how Docker works and know its most used commands. There are tons of tutorials on the net to get familiar with Docker. Please take time to play with Docker a little bit so that you are proficient enough to know how to build and run images, start containers, etc... Be sure that this is not time wasted just to run this project. Docker is a top notch technology (although based on ancient roots) widely used in the computer industry and at the heart of many IT ecosystems.

<h2>SDRangel section</h2>

The files contained in the `sdrangel` directory are used to build and run SDRangel images. Please check the readme inside this folder for further information

<h2>SDRangelCli section</h2>

The files contained in the `sdrangelcli` directory are used to build and run SDRangelCli images. Please check the readme inside this folder for further information