#!/bin/bash

CONFIG_FILE=${IRIS_CONFIGAPI_FILE}

configure() {
    envsubst < ${CONFIG_FILE} > ${CONFIG_FILE}.resolved
    iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
zpm "install config-api"
Set sc = ##class(Api.Config.Services.Loader).Load("${CONFIG_FILE}.resolved")
Set sc = ##class(SYS.ECP).ServerAction("${DATASERVER_NAME}",3,1)
halt
END

}

configure
exit 0
