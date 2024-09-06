## 👋 Welcome to remotely 🚀  

remotely README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update remotely
```
  
## Install and run container
  
```shell
mkdir -p "$HOME/.local/share/srv/docker/remotely/rootfs"
git clone "https://github.com/dockermgr/remotely" "$HOME/.local/share/CasjaysDev/dockermgr/remotely"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/remotely/rootfs/." "$HOME/.local/share/srv/docker/remotely/rootfs/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-remotely \
--hostname remotely \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$HOME/.local/share/srv/docker/casjaysdevdocker-remotely/rootfs/data:/data:z" \
-v "$HOME/.local/share/srv/docker/casjaysdevdocker-remotely/rootfs/config:/config:z" \
-p 80:80 \
casjaysdevdocker/remotely:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/remotely
    container_name: casjaysdevdocker-remotely
    environment:
      - TZ=America/New_York
      - HOSTNAME=remotely
    volumes:
      - "$HOME/.local/share/srv/docker/casjaysdevdocker-remotely/rootfs/data:/data:z"
      - "$HOME/.local/share/srv/docker/casjaysdevdocker-remotely/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/remotely
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/remotely" "$HOME/Projects/github/casjaysdevdocker/remotely"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/remotely"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
