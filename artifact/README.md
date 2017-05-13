# Functional Pearl: A Unified Approach to Solving Seven Programming Problems

This file explains how to build and optionally archive the Docker image `artifact35-AUAS7PP` if you don't already have one.  Read `ArtifactOverview.md` to use an existing image.


## Install Docker

Download and install the free version of Docker for your OS: https://www.docker.com/community-edition#/download

We've tested with "Docker version 17.03.1-ce, build c6d412e" but more recent versions are probably fine.

Once installed, verify that things are working by running: `docker run --rm hello-world`


## Build image

From this directory (it has the Dockerfile) run `docker build -t artifact35-AUAS7PP .`

This creates the `artifact35-AUAS7PP` image.


## Save image to archive file (optional)

Once you've built the image, you can save it to an archive file for distribution by running: `docker save -o artifact35-AUAS7PP.tar`

Given an image archive with the same name, you can import it by running: `docker load -i artifact35-AUAS7PP.tar`
