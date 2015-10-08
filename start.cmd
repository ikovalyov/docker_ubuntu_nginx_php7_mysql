docker-machine start dev
docker-machine ssh dev "mkdir /home/docker/docker"
docker-machine ssh dev "sudo mount -t vboxsf -o rw,uid=1000,gid=1000 /home/docker/docker /home/docker/docker"
docker-machine ssh dev "docker start volume"