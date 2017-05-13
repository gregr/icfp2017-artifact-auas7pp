FROM alpine:3.5
ENV CHEZ_SCHEME_VERSION 9.4
ENV BUILD /tmp/BUILD

# Chez Scheme depends on make, gcc, ncurses, and X11 according to:
# https://github.com/cisco/ChezScheme/blob/06f858f9a505b9d6fb6ca1ac97234927cb2dc641/BUILDING#L41-L44
# `musl-dev` is Alpine's version of `libc-dev`.
# `openssl` is needed to `wget` from `https://github.com`.
# Even curl is needed!  This seems kind of sketchy:
# https://github.com/cisco/ChezScheme/blob/06f858f9a505b9d6fb6ca1ac97234927cb2dc641/configure#L305

# Ultimately there is a build error, but it doesn't seem to impact anything:
# Exception in $fasl-file-equal?: code comparison failed while comparing ../boot/a6le/sbb and ../boot/a6le/petite.boot within fasl entry 103
# make[4]: *** [Mf-base:266: checkboot] Error 255

RUN mkdir -p "$BUILD" && cd "$BUILD" \
 # Install packages needed at runtime separately from build-only dependencies.
 && apk add --no-cache ncurses libx11 \
 # Install, group build-only dependencies as virtual package for easy removal.
 && apk add --no-cache --virtual .build-dependencies make gcc musl-dev ncurses-dev libx11-dev curl openssl \
 # Download, extract, build and install, then clean up.
 && wget "https://github.com/cisco/ChezScheme/archive/v$CHEZ_SCHEME_VERSION.tar.gz" \
 && tar -xzf "v$CHEZ_SCHEME_VERSION.tar.gz" \
 && cd "$BUILD/ChezScheme-$CHEZ_SCHEME_VERSION" && ./configure && make install \
 && cd / && rm -rf "$BUILD" \
 # Remove the build-only dependencies virtual package.
 && apk del .build-dependencies

# Optionally install text editors.  You can comment out anything you don't use.
# (Space usage: nano ~0.4MB, vim ~23.4MB, emacs ~118MB)
RUN apk add --no-cache nano
RUN apk add --no-cache vim
RUN apk add --no-cache emacs

WORKDIR /artifact
COPY src/mk/LICENSE src/mk/README.md src/mk/*.scm ./mk/
COPY src/evalo-*.scm src/intro-examples.scm src/love-in-99k-ways.scm src/challenge-*.scm src/all-challenges.scm ./
COPY ArtifactOverview.md ./

CMD ["/bin/sh"]
