## Install

Install Docker.

Instructions for OSX El Capitan and later:

* download and install (stable version from https://docs.docker.com/docker-for-mac/install/), then run (It will ask for privileged access, then appear in the top status bar.)
* verify that things are working by running `docker run hello-world`


## Build image

From this directory (it has the Dockerfile) run `docker build -t artifact35-AUAS7PP .`

This creates the `artifact35-AUAS7PP` image.


## Export/import image (optional)

Once you've built the image, you can export it to file for distribution by running: `docker save -o artifact35-AUAS7PP.tar`

Given an image archive with the same name, you can import it by running: `docker load -i artifact35-AUAS7PP.tar`


## Start a container

To start in a shell, run: `docker run -it --rm artifact35-AUAS7PP`

This runs the `artifact35-AUAS7PP` image in a container set up for interaction (`-it`) that will automatically be removed upon exit (`--rm`).

To directly enter the Scheme REPL instead, run: `docker run -it --rm artifact35-AUAS7PP scheme`


## Share files (optional)

The image is built with minimal installations of nano, vim, and emacs, to allow editing files directly in a running container.  But if you'd prefer to edit files locally, you can ferry them across a directory shared with the host system.

To share a directory, use the `-v HOST-PATH:CONTAINER-PATH` option to map `HOST-PATH` to `CONTAINER-PATH` (note, absolute paths must be used).  If `HOST-PATH` doesn't already exist, it will automatically be created.

For instance, to map the local directory `shared` (relative to the current path) to `/var/shared` on the container, run:

`docker run -it --rm -v "$(pwd)"/shared:/var/shared artifact35-AUAS7PP`


## Explore

Look in `src/README.md` for more instructions.
