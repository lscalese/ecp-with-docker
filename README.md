# IRIS ECP With Docker

This a repository sample to configure programatically and ECP application server and ECP data server with Docker.  

We use [ZPM Package manager](https://openexchange.intersystems.com/package/ObjectScript-Package-Manager) and [config-api](https://openexchange.intersystems.com/package/Config-API).  


## Prerequisites

 * WRC Access.  

## Prepare your system

### Get an IRIS License

If you don't have a valid Docker License for IRIS yet connect to [Worldwide Respnse Center (WRC)](https://wrc.interystems.com) with your credentials.  
Click "Actions" --> "Online distribtion", then "Evaluations" button and select "Evaluation License", fill the form.  
Copy the `iris.key` to your home directory.  


### Create users and groups

This sample use local files to mount in the containers.    
To avoid `access denied` errors we need to create irisuser and irisowner users and groups.

```bash
sudo useradd --uid 51773 --user-group irisowner
sudo useradd --uid 52773 --user-group irisuser
sudo groupmod --gid 51773 irisowner
sudo groupmod --gid 52773 irisuser
```

### Login to Intersystems Containers Registry

Our [docker-compose.yml](./docker-compose.yml) uses references to `containers.intersystems.com`.  
So you need to login to Intersystems Containers Registry to pull the used images.  
If you don't remember your password for the docker login to ICR, logon to https://containers.intersystems.com/ with WRC account.  


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
docker-compose up --scale ecp-demo-app-server=2
```

### Test

Open an IRIS terminal on the application server.

```bash
docker exec -it ecp-with-docker_ecp-demo-app-server_1 session iris
```

Set a global mapped to the remote database.

```objectscript
Set ^demo.ecp = $zdt($h,3,1)_" Set from application server"
```

Now, check if the data has been set on the data server.
Open an IRIS terminal on the data server

```bash
docker exec -it ecp-demo-data-server iris session iris
```

Write ^demo.ecp global entry from `MYAPPDATA` database:

```objectscript
Write ^["^^/usr/irissys/mgr/myappdata/"]demo.ecp
```

## Access to portals

Data server : http://localhost:81/csp/sys/utilhome.csp  

To connect to the portal mangement of application server, you have to retrieve the exposed port number with docker ps -a command:

```
docker ps -a
CONTAINER ID   IMAGE      COMMAND                  CREATED       STATUS                 PORTS                                                                                     NAMES
2bbe4dbd95f0   ecp-demo   "/tini -- /iris-main…"   7 hours ago   Up 7 hours (healthy)   1972/tcp, 2188/tcp, 53773/tcp, 54773/tcp, 0.0.0.0:49167->52773/tcp, :::49167->52773/tcp   ecp-with-docker_ecp-demo-app-server_2
46c844a2f1ab   ecp-demo   "/tini -- /iris-main…"   7 hours ago   Up 7 hours (healthy)   1972/tcp, 2188/tcp, 53773/tcp, 54773/tcp, 0.0.0.0:49168->52773/tcp, :::49168->52773/tcp   ecp-with-docker_ecp-demo-app-server_1
79bff80ea342   ecp-demo   "/tini -- /iris-main…"   7 hours ago   Up 7 hours (healthy)   1972/tcp, 2188/tcp, 53773/tcp, 54773/tcp, 0.0.0.0:85->52773/tcp, :::85->52773/tcp         ecp-demo-data-server
```

In this example, ports are : 

 * 49167 for ecp-with-docker_ecp-demo-app-server_2 http://localhost:49167/csp/sys/utilhome.csp
 * 49168 for ecp-with-docker_ecp-demo-app-server_1 http://localhost:49168/csp/sys/utilhome.csp
