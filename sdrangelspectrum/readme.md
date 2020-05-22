<h1>Building and running SDRangelSpectrum in a Docker container</h1>

This should work the same in all environments.

<h2>Build image</h2>

Use the `build.sh` script to produce the `sdrangelspectrum/node:latest` image

The build command can control from which repository and from which branch you are cloning the source of SDRangelSpectrum. You can also give a different tag version than the default.

  - `-r` specifies from which URL you are cloning the `sdrangelspectrum` repository (default is `https://github.com/f4exb/sdrangelspectrum.git`). The repository name hash key is used during the clone step so that build caches can be kept separately for each repository.
  - `-b` specifies which branch you are checking out in the clone (default is `master`).
  - `-c` specifies an arbitrary commit tag. This is to force a fresh clone of the SDRangelSpectrum repository. If that tag changes from the one previously used then the clone layer in the build cache is refreshed.
    - By default this is the current timestamp so each time the build is run a new cache is built
    - You can specify the commit SHA1 so that a fresh copy will be taken only if a new commit took place
  - `-i` specifies the image name (default is `sdrangelspectrum`)
  - `-t` specifies the tag version image (default is `latest`)

<h2>Run image</h2>

Use the `run.sh` script without options to run the image. By default it listens to port `8081` on the host and uses the `latest` image version. You may use the `-p` and `-t` options respectively to specify your own values.

The available options are:

  - `-i` specifies the image name (default is `sdrangelspectrum`)
  - `-t` specifies the tag version image (default is `latest`)
  - `-c` specifies a container name. Default is `sdrangelspectrum`
  - `-p` specifies the port on the host to which the UI will listen. Default is `8081`.
