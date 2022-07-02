#!/bin/bash

CONFIG_FILE=${IRIS_CONFIGAPI_FILE}

configure() {
    envsubst < ${CONFIG_FILE} > ${CONFIG_FILE}.resolved
    iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
Set sc = ##class(Api.Config.Services.Loader).Load("${CONFIG_FILE}.resolved")
do { w !,"accept pending ecp app server list" s i=\$i(i),rset = ##class(%ResultSet).%New("SYS.ECP:SSLPendingConnections") d rset.Execute(),rset.Next() s cn = rset.Get("SSLComputerName") w " Accept cn ",cn d:cn'="" ##class(SYS.ECP).RemoveFromPendingList(cn,1) d rset.%Close() hang 5 } while (i<20)
halt
END

}

configure
exit 0
