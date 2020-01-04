

container_tag=v0.93
sudo docker build --rm -t local/centos-systemd:${container_tag} .


sudo docker stop hadoop1 hadoop2 hadoop3
sudo docker rm hadoop1 hadoop2 hadoop3


--- run hadoop1:

container_name=hadoop1

sudo docker run -d \
--name ${container_name} \
-p 50070:50070 \
-p 8088:8088 \
-p 19888:19888 \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}


container_name=hadoop2

sudo docker run -d \
--name ${container_name} \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}


container_name=hadoop3

sudo docker run -d \
--name ${container_name} \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}
