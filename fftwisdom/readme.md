<h1>Building and running fftw-wisdom command in a Docker container</h1>

This should work the same in all environments.

<h2>Build image</h2>

Use the `build.sh` script to produce the `fftwisdom:latest` image

  - `-t` specifies the tag version image (default is `latest`)
  - `-f` specifies an alternate Dockerfile to the default `Dockerfile` used for `x86-64` architecture. This can be `armv8.ubuntu.Dockerfile` for `armv8`

<h2>Run image</h2>

Use the `run.sh` script without options to run the image and produce a `fftw-wisdom` file with common fft sizes in the `~/.config/sdrangel` directory.

The available options are:

  - `-t` specifies the tag version image (default is `latest`)
  - `-c` specifies a container name. Default is `fftwisdom`
  - `-s` specifies FFT sizes in fftwf-wisdom format (default `128 256 512 1024 b128 b256 b512 b1024`)
  - `-f` specifies the FFT wisdom file name in `~/.config/sdrangel` (default `fftw-wisdom`)
