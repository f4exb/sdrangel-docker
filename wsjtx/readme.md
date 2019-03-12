<h1>Container for WSJT-X</h1>

<h2>Introduction</h2>

When running SDRangel in a container some significant delay is introduced in the audio (normally a pulseaudio virtual device). This delay can be as large as ~4s and WSJT-X cannot synchronize its decoders that are based on the system clock. WSJT-X cannot be configured with a specified delay either.

The [libfaketime](https://github.com/wolfcw/libfaketime) library can tweak the clock as a program sees it by capturing the system calls for time and introducing a delay without affecting your system clock in any way.

To do the magic it uses LD_PRELOAD trick. You can try it from the command line if you have cloned and built `libfaketime` in say `/opt/build/libfaketime` and installed WSJT-X in `/opt/install/wsjtx`:

<pre><code>LD_PRELOAD=/opt/build/libfaketime/src/libfaketime.so.1 FAKETIME="-4s" /opt/install/wsjtx/bin/wsjtx</code></pre>

Here for your convenience we will provide ways to create a container with WSJT-X and `libfaketime` built from source and used to introduce a specific delay.

<h2>Build image</h2>

A `wsjtx/bionic:libfaketime` image is created by running `./build.sh`

<h2>Run image</h2>

The `run.sh` script can be used.

`xhost` utility should be installed in your system.

A `WSJT-X.ini` file is created in your home directory that will allow settings to be persistent. It is mapped to `/home/wsjtx/.config/WSJT-X.ini` in the container.

You can use the following options:

  - `-t version`: image version if different from `libfaketime`
  - `-d delay`: delay in seconds (defaut `4`)