# Functional Pearl: A Unified Approach to Solving Seven Programming Problems

http://icfp17.sigplan.org/event/icfp-2017-papers-functional-pearl-a-unified-approach-to-solving-seven-programming-problems

The paper and pre-built Docker image:
http://dl.acm.org/citation.cfm?id=3110252&CFID=976617079

The livecode.io version of the paper:
http://io.livecode.ch/learn/namin/icfp2017-artifact-auas7pp

The livecode.io miniKanren tutorial:
http://io.livecode.ch/learn/webyrd/webmk


This file explains how to build and optionally archive the Docker image `artifact35-auas7pp` if you don't already have one.  Read `ArtifactOverview.md` to use an existing image.


## Install Docker

Download and install the free version of Docker for your OS: https://www.docker.com/community-edition#/download

We've tested with "Docker version 17.03.1-ce, build c6d412e" but more recent versions are probably fine.

Once installed, verify that things are working by running: `docker run --rm hello-world`


## Build image

From this directory (it has the Dockerfile) run `docker build -t artifact35-auas7pp .`

This creates the `artifact35-auas7pp` image.


## Save image to archive file (optional)

Once you've built the image, you can save it to an archive file for distribution by running: `docker save -o artifact35-auas7pp.tar artifact35-auas7pp`

Given an image archive with the same name, you can import it by running: `docker load -i artifact35-auas7pp.tar`
