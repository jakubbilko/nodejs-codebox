FROM ubuntu:trusty
MAINTAINER "Syncano DevOps Team" <devops@syncano.com>

ENV LAST_REFRESHED 2016-03-25
ENV SYNCANO_APIROOT https://api.syncano.io/

RUN groupadd -r syncano && \
    useradd -u 1000 -r -g syncano syncano -d /tmp -s /bin/bash && \
    mkdir /home/syncano && \
    chown -R syncano /home/syncano

# enable everyone to use /tmp
RUN chmod 1777 /tmp
# -- CUT BEGIN --

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.6.0
ENV NODE_PATH /home/syncano/v1.0/node_modules

RUN apt-get update && apt-get install -y \
  curl \
  git \
  imagemagick \
  graphicsmagick

# copied from: https://github.com/nodejs/docker-node/blob/5d433ece4d221fac7e38efbec25ffea2dea56286/5.2/Dockerfile
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

COPY scripts/* /usr/bin/
COPY package.json* /home/syncano/
COPY *.tar.gz /tmp/

WORKDIR /home/syncano/
RUN tar xzvf /tmp/04.tar.gz && \
    mv package.json.v04 v0.4/package.json && \
    cd v0.4 && \
    npm install

RUN tar xzvf /tmp/10.tar.gz && \
    mv package.json.v10 v1.0/package.json && \
    cd v1.0 && \
    npm install

# -- CUT END --
USER syncano
WORKDIR /tmp
CMD "node"
