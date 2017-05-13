# Functional Pearl: A Unified Approach to Solving Seven Programming Problems

## Getting started

### Install Docker

Download and install the free version of Docker for your OS: https://www.docker.com/community-edition#/download

We've tested with "Docker version 17.03.1-ce, build c6d412e" but more recent versions are probably fine.

Once installed, verify that things are working by running: `docker run --rm hello-world`


### Load the Docker image

Load the archived image into Docker by running: `docker load -i artifact35-AUAS7PP.tar`


### Start a container

To start a container, run: `docker run -it --rm artifact35-AUAS7PP`

This runs the `artifact35-AUAS7PP` image in a container set up for interaction (`-it`).  This container will automatically be removed upon exit (`--rm`).


### Share files with a container (optional)

The image is built with minimal installations of nano, vim, and emacs, to allow editing files directly in a running container.  But if you'd prefer to manipulate files locally, you can ferry them across a directory shared with the host system.

To share a directory, use the `-v HOST-PATH:CONTAINER-PATH` option to map `HOST-PATH` to `CONTAINER-PATH` (note, absolute paths must be used).  If `HOST-PATH` doesn't already exist, it will automatically be created.

For instance, to map the host directory `shared` (relative to the current path) to `/var/shared` on the container, run:

`docker run -it --rm -v "$(pwd)"/shared:/var/shared artifact35-AUAS7PP`


### Run the challenge test suite

Once in a container, start the test suite by running: `scheme --script challenges-all.scm`

There's no need to wait for this to finish before moving on to something else.  Multiple containers can be running at the same time without interfering with each other, as each one maintains its own state, including an independent file system.  So, while the tests are running, make efficient use of your time by starting another container to continue exploring.
