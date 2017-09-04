# Building the Docker image

This file explains how to build and optionally archive the Docker image `artifact35-auas7pp` if you don't already have one.  Read [SETUP-DOCKER-EVAL.md](https://github.com/gregr/icfp2017-artifact-auas7pp/blob/master/SETUP-DOCKER-EVAL.md) to use an existing image.


## Install Docker

Download and install the free version of Docker for your OS: https://www.docker.com/community-edition#/download

We've tested with "Docker version 17.03.1-ce, build c6d412e" but more recent versions are probably fine.

Once installed, verify that things are working by running: `docker run --rm hello-world`


## Build image

From this directory (it has the Dockerfile) run: `docker build -t artifact35-auas7pp .`

This creates the `artifact35-auas7pp` image.


## Save image to archive file (optional)

Once you've built the image, you can save it to an archive file for distribution by running: `docker save -o artifact35-auas7pp.tar artifact35-auas7pp`

Given an image archive with the same name, you can import it by running: `docker load -i artifact35-auas7pp.tar`
