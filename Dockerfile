ARG IMAGE=containers.intersystems.com/intersystems/iris:2022.2.0.281.0

# Don't need to download the image from WRC. It will be pulled from ICR at build time.

FROM $IMAGE

USER root

# Install iputils-arping to have an arping command.  It's required to configure Virtual IP.
# Download the latest ZPM version (ZPM is included only with community edition). 
RUN apt-get update && apt-get install iputils-arping gettext-base && \
    rm -rf /var/lib/apt/lists/*

USER ${ISC_PACKAGE_MGRUSER}

WORKDIR /home/irisowner/demo

RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
        iris session IRIS < iris.script && \
    iris stop IRIS quietly