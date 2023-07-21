<h1>Building and running SDRangelCli in a Docker container</h1>

This should work the same in all environments.

<h2>Build image</h2>

Use the `build.sh` script to produce the `sdrangelcli/node:latest` image

The build command can control from which branch you are cloning the source of SDRangelCli. You can also give a different tag version than the default.

  - `-b` specifies which branch you are checking out in the clone (default is `master`). The image name of the image tag (after the /) will be the branch name e.g. `sdrangel/dev:latest`
  - `-c` specifies an arbitrary commit label. This is to force a fresh clone of the SDRangelCli repository. If that label changes from the one previously used then the clone layer in the build cache is refreshed.
    - By default this is the current timestamp so each time the build is run a new cache is built
    - You can specify the commit SHA1 so that a fresh copy will be taken only if a new commit took place
  - `-i` specifies the image name (default is `sdrangelcli`)
  - `-t` specifies the tag version image (default is `latest`)
  - `-f` specifies an alternate Dockerfile, e.g. `armv8.Dockerfile` for ARM architectures like RPi 3 or 4 (default is `.` for `Dockerfile` in current directory)

<h2>Run image</h2>

Use the `run.sh` script without options to run the image. By default it listens to port `8080` on the host and uses the `master/latest` image version. You may use the `-p` and `-t` options respectively to specify your own values.

The available options are:

  - `-b` specifies which branch you are checking out in the clone (default is `master`). The image name of the image tag (after the /) will be the branch name e.g. `sdrangel/dev:latest`
  - `-i` specifies the image name (default is `sdrangelcli`)
  - `-t` specifies the tag version image (default is `latest`)
  - `-c` specifies a container name. Default is `sdrangelcli`
  - `-p` specifies the port on the host to which the UI will listen. Default is `8080`.

By default the client connects to the SDRangel API at `localhost:8091` which is the default when you start a SDRangel container on the same machine.
