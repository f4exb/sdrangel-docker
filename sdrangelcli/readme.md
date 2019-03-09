<h1>Building and running SDRangelCli in a Docker container</h1>

This should work the same in all environments.

  - Use the `build.sh` script to produce the `sdrangelcli/node:latest` image
  - Use the `run.sh` script without options to run the image that listens to port `8080` on the host and uses the `latest` image version. You may use the `-p` and `-t` options respectively to specify your own values.

By default the client connects to the SDRangel API at `localhost:8091` which is the default when you start a SDRangel container on the same machine.