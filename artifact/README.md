
## INSTALL

Install Docker.

Instructions for OSX El Capitan and later:

* download and install (stable version from https://docs.docker.com/docker-for-mac/install/), then run (It will ask for privileged access, then appear in the top status bar.)
* verify that things are working by running `docker run hello-world`

## BUILD IMAGE

From this directory (it has the Dockerfile) run `docker build -t scheme-repl .`

This creates the `scheme-repl` image.

## RUN

To enter the REPL run: `docker run -it --rm scheme-repl`

This runs the `scheme-repl` image in a container set up for interaction (`-it`) that will automatically be removed upon exit (`--rm`).
