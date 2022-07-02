ARG IMAGE=containers.intersystems.com/intersystems/iris:2021.1.0.215.0
# Don't need to download the image from WRC. It will be pulled from ICR at build time.

FROM $IMAGE

USER root

COPY session.sh /
COPY iris.key /usr/irissys/mgr/iris.key

# /opt/demo will be our working directory used to store our configuration files and other installation files.
# Install iputils-arping to have an arping command.  It's required to configure Virtual IP.
# Download the latest ZPM version (ZPM is included only with community edition). 
RUN mkdir /opt/demo && \
    chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/demo && \
    chmod 666 /usr/irissys/mgr/iris.key && \
    apt-get update && apt-get install iputils-arping gettext-base && \
    wget -O /opt/demo/zpm.xml https://pm.community.intersystems.com/packages/zpm/latest/installer

USER ${ISC_PACKAGE_MGRUSER}

WORKDIR /opt/demo

# Set Default Mirror role to master.
# It will be overridden on docker-compose file at runtime (master for the first instance, backup, and report)
ARG IRIS_MIRROR_ROLE=master

# Copy the content of the config-files directory into /opt/demo.
# Currently we have only created a simple-config to setup our database and global mapping.
# Later in this article we will add other configuration files to set up the mirror.
ADD config-files .

SHELL [ "/session.sh" ]

# Install ZPM
# Use ZPM to install config-api
# Load simple-config.json file with config-api to:
#  - create "myappdata" database,
#  - add a global mapping in namespace "USER" for global "demo.*" on "myappdata" database.
# Basically, the entry point to install your ObjectScript application is here. 
# For this sample, we will load simple-config.json to create a simple database and a global mapping.
RUN \
Do $SYSTEM.OBJ.Load("/opt/demo/zpm.xml", "ck") \
zpm "install config-api" \
Set sc = ##class(Api.Config.Services.Loader).Load("/opt/demo/simple-config.json")

# Copy the mirror initialization script. 
# COPY init_mirror.sh / # removed and replaced by init_primary.sh, init_master.sh, init_report.sh and mounted at container startup.
