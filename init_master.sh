#!/bin/bash

# Database used to test the mirror.
DATABASE=/usr/irissys/mgr/myappdata

# Directory contain myappdata backuped by the master to restore on other nodes and making mirror.
BACKUP_FOLDER=/opt/backup

# Mirror configuration file in json config-api format for the master node.
MASTER_CONFIG=/opt/demo/mirror-master.json

# The mirror name...
MIRROR_NAME=DEMO

# Mirror Member list.
MIRROR_MEMBERS=BACKUP,REPORT

# Performed on the master.
# Load the mirror configuration using config-api with /opt/demo/simple-config.json file.
# Start a Job to auto-accept other members named "backup" and "report" to join the mirror (avoid manuel validation in portal management).
configure_master() {
rm -rf $BACKUP_FOLDER/IRIS.DAT
envsubst < ${MASTER_CONFIG} > ${MASTER_CONFIG}.resolved
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
Set sc = ##class(Api.Config.Services.Loader).Load("${MASTER_CONFIG}.resolved")
Set ^log.mirrorconfig(\$i(^log.mirrorconfig)) = \$SYSTEM.Status.GetOneErrorText(sc)
Job ##class(Api.Config.Services.SYS.MirrorMaster).AuthorizeNewMembers("${MIRROR_MEMBERS}","${MIRROR_NAME}",600)
Hang 2
Halt
END
}

# Performed by the master, make a backup of /usr/irissys/mgr/myappdata
make_backup() {
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(SYS.Database).DismountDatabase(\"${DATABASE}\")"
md5sum ${DATABASE}/IRIS.DAT
cp ${DATABASE}/IRIS.DAT ${BACKUP_FOLDER}/IRIS.TMP
mv ${BACKUP_FOLDER}/IRIS.TMP ${BACKUP_FOLDER}/IRIS.DAT
chmod 777 ${BACKUP_FOLDER}/IRIS.DAT
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(SYS.Database).MountDatabase(\"${DATABASE}\")"
}

configure_master
make_backup

exit 0