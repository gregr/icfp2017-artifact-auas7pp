# Setting up Docker for artifact evaluation

This file describes how to set up Docker for artifact evaluation, with instructions for running and validating the tests once you're in the image.

It's assumed that you have a pre-built image available for use.  If you don't, you can obtain it here: https://dl.acm.org/ft_gateway.cfm?id=3110252&type=zip&path=%2F3120000%2F3110252%2Fsupp%2Ficfp17%2Dmain35%2Ds%2Ezip&supp=1&dwn=1&CFID=979103363&CFTOKEN=46849167

You can also build it yourself by following the instructions in: [BUILD-DOCKER-IMAGE.md](https://github.com/gregr/icfp2017-artifact-auas7pp/blob/master/BUILD-DOCKER-IMAGE.md)


## Getting started

### Install Docker

Download and install the free version of Docker for your OS: https://www.docker.com/community-edition#/download

We've tested with "Docker version 17.03.1-ce, build c6d412e" but more recent versions are probably fine.

Once installed, verify that things are working by running: `docker run --rm hello-world`

If it complains about not being able to connect to the Docker daemon, make sure you've started the Docker app itself after installation (this step depends on your OS).


### Load the Docker image

If you're in the same directory as the archived image, load it into Docker by running: `docker load -i artifact35-auas7pp.tar`

Otherwise, make sure you specify the full path to the archive file.


### Start a new container

To start a new container, run: `docker run -it artifact35-auas7pp`

This runs the `artifact35-auas7pp` image in a container set up for interaction (`-it`).

After exiting, this container's state will persist.  To instead start a new throwaway container (it removes itself after exiting), add the `--rm` flag, running: `docker run -it --rm artifact35-auas7pp`


### Share files with a container (optional)

This is optional, but sharing a directory with the host system is strongly encouraged in order to preserve any edited or generated files (such as the test output log).

The image is built with minimal installations of nano, vim, and emacs, to allow editing files directly in a running container.  But if you'd prefer to manipulate files locally, you can ferry them across a shared directory.

To share a directory, use the `-v HOST-PATH:CONTAINER-PATH` option to map `HOST-PATH` to `CONTAINER-PATH` (note, absolute paths must be used).  If `HOST-PATH` doesn't already exist, it will automatically be created.

For instance, to map the host directory `shared` (relative to the current path) to `/artifact/shared` on a normal container, run:

`docker run -it -v "$(pwd)"/shared:/artifact/shared artifact35-auas7pp`

This assumes you're in a bash-like environment, and can use `"$(pwd)"` to retrieve the current directory.

To run with a throwaway container instead, add the `--rm` flag, running:

`docker run -it --rm -v "$(pwd)"/shared:/artifact/shared artifact35-auas7pp`


### Manipulate existing containers (optional)

You will need to know the container's name to manipulate it.  Containers are given arbitrary names when they're first created.  View the names of all your containers by running: `docker ps -a`

To restart and re-enter an exited container, run: `docker start -ia CONTAINER-NAME`

To remove an exited container, run: `docker rm CONTAINER-NAME`


### Get familiar with your surroundings

Upon starting the container, you should end up with the prompt: `/artifact #`

This artifact runs on a tiny Linux OS.  If you're new to a Linux system, here are some commands for finding your way around:

- `ls` will list all the file names in your current directory.
- `less FILENAME` will allow you to read a file without editing it.  You can scroll up and down with the keyboard arrows.
- `nano FILENAME` will allow you to open a file in a text editor.  All the editing commands will be listed at the bottom of the screen for your convenience.
- `exit` will allow you to leave the shell, exiting the container.  The prompt should change back to what it was before you started the container.


### Start the challenge test suite

Once in a container, if you've opted to share a directory as suggested, start the test suite by running: `scheme --script all-challenges.scm | tee shared/test-output.log`

Otherwise, start the test suite by running: `scheme --script all-challenges.scm | tee test-output.log`

The log is displayed as the tests run, but it will also be written to the file `test-output.log` in case you'd like to reference it later.  If you're willing to share a directory with the host, it's a good idea to copy this (and any other generated or edited files) to that directory, for backup.

These tests may take some time to complete (currently about 10 minutes).  While the tests are running, make efficient use of your time by starting another container if you'd like to continue with the "Step-by-Step" section.  Multiple containers for the same image can safely be running at the same time without interfering with each other, as each one maintains its own state, including an independent file system (aside from any explicit sharing you've set up).


### Validate the test suite run once it has completed

Look over the test output log to verify that there are no failures.  Failures are loud and obnoxious, so they should be easy to spot.  If you haven't edited any of the tests or implementations, there should be no failures.

If you've made changes, it could affect the order in which correct answers appear.  In fact, completely different, but still correct, answers could show up.  These differences will still be flagged as test failures even if there isn't really a problem.  You'll have to look at the output carefully to determine if this is the case.

Some tests produce timings and resource usage, for measuring performance.  Don't be alarmed by these.
