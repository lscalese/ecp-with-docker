# IRIS ECP With Docker

This a repository sample to configure programatically and ECP application server and ECP data server with Docker.  

We use [ZPM Package manager](https://openexchange.intersystems.com/package/ObjectScript-Package-Manager) and [config-api](https://openexchange.intersystems.com/package/Config-API).  


## Prerequisites

 * WRC Access.  

## Prepare your system

### Get an IRIS License

If you don't have a valid Docker License for IRIS yet connect to [Worldwide Respnse Center (WRC)](https://wrc.interystems.com) with your credentials.  
Click "Actions" --> "Online distribtion", then "Evaluations" button and select "Evaluation License", fill the form.  
Copy the `iris.key` to this repository directory.  


### Create users and groups

This sample use local files to mount in the containers.    
To avoid `access denied` errors we need to create irisuser and irisowner users and groups.

```bash
sudo useradd --uid 51773 --user-group irisowner
sudo useradd --uid 52773 --user-group irisuser
sudo groupmod --gid 51773 irisowner
sudo groupmod --gid 52773 irisuser
sudo chgrp irisowner ./backup
```

### Login to Intersystems Containers Registry

Our [docker-compose.yml](./docker-compose.yml) uses references to `containers.intersystems.com`.  
So you need to login to Intersystems Containers Registry to pull the used images.  
If you don't remember your password for the docker login to ICR, open this page https://login.intersystems.com/login/SSO.UI.User.ApplicationTokens.cls and you can retrieve your docker token.  


```bash
docker login -u="YourWRCLogin" -p="YourPassWord" containers.intersystems.com
```

### Generate certificates


```
# sudo is needed due chown, chgrp, chmod ...
sudo ./gen-certificates.sh
```

Generated certficates will be in `./certificates` directory for IRIS instances.  

Certficates files overview : 

| File | Container | Description |
|--- |--- |--- |
| ./certificates/CA_Server.cer | appsrv, datasrv | Authority server certificate|
| ./certificates/app_server.cer | appsrv1 | Certificate for IRIS application server instance |
| ./certificates/app_server.key | appsrv1| Related private key |
| ./certificates/data_server.cer | datasrv | Certificate for IRIS data server instance |
| ./certificates/data_server.key | datasrv | Related private key |


### Build and run containers

```
docker-compose build --no-cache
docker-compose up
```

### Test

Open an IRIS terminal on the application server.

```bash
docker exec -it app-server-1 iris session iris
```

Set a global mapped to the remote database.

```objectscript
Set ^demo.ecp = $zdt($h,3,1)_" Set from application server"
```

Now, check if the data has been set on the data server.
Open an IRIS terminal on the data server

```bash
docker exec -it data-server iris session iris
```

Write ^demo.ecp global entry from `MYAPPDATA` database:

```objectscript
Write ^["^^/usr/irissys/mgr/myappdata/"]demo.ecp
```

## Access to portals

Application server : http://localhost:84/csp/sys/utilhome.csp  
Data server : http://localhost:85/csp/sys/utilhome.csp  
