

# Database used to test the mirror.
DATABASE=/usr/irissys/mgr/myappdata

# Directory contain myappdata backuped by the master to restore on other nodes and making mirror.
BACKUP_FOLDER=/opt/backup

# Mirror configuration file in json config-api format for the backup node.
BACKUP_CONFIG=/opt/demo/mirror-backup.json

# The mirror name...
MIRROR_NAME=DEMO

# Mirror Member list.
MIRROR_MEMBERS=BACKUP,REPORT

# Restore the mirrored database "myappdata".  This restore is performed on "backup" and "report" node.
restore_backup() {
sleep 5
while [ ! -f $BACKUP_FOLDER/IRIS.DAT ]; do sleep 1; done
sleep 2
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(SYS.Database).DismountDatabase(\"${DATABASE}\")"
cp $BACKUP_FOLDER/IRIS.DAT $DATABASE/IRIS.DAT
md5sum $DATABASE/IRIS.DAT
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(SYS.Database).MountDatabase(\"${DATABASE}\")"
}

# Configure the "backup" member
#  - Load configuration file /opt/demo/mirror-backup.json if this instance is the backup

configure_backup() {
sleep 5
envsubst < $1 > $1.resolved
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
Set sc = ##class(Api.Config.Services.Loader).Load("$1.resolved")
Halt
END
}

restore_backup
configure_backup $BACKUP_CONFIG

exit 0