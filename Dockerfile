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

SHELL [ "/session.sh" ]

# Install ZPM
# Use ZPM to install config-api
# Set the max server connexion to 2 
RUN \
Do $SYSTEM.OBJ.Load("/opt/demo/zpm.xml", "ck") \
zpm "install config-api" \
Set sc = ##class(Api.Config.Services.Loader).Load( {"config" : { "MaxServerConn" : 2 } } )