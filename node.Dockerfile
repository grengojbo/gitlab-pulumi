# syntax = docker/dockerfile:experimental
# Interim container so we can copy pulumi binaries
# Must be defined first

# The runtime container
# https://hub.docker.com/r/pulumi/pulumi-nodejs/tags?page=1&ordering=last_updated
FROM pulumi/pulumi-nodejs:3.30.0

# Install needed tools, like git
RUN apt-get update -y && \
    apt-get install -y \
    apt-transport-https curl gnupg2 software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update -y && apt-cache policy docker-ce \
    && apt-get install -y docker-ce

RUN npm install -g npm

COPY tsconfig.json .
COPY package.json .
COPY package-lock.json .
RUN npm ci --no-progress
COPY run-node-pulumi.sh /usr/bin/run-pulumi.sh
WORKDIR /app