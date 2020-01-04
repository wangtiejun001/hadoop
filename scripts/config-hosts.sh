####### hadoop1 #######
tar_container_name=hadoop1
host_name=node01.kaikeba.com
sudo docker exec -it ${tar_container_name} sh -c "echo ${host_name} > /etc/hostname"


###
src_container_name=hadoop1
host_config='node01.kaikeba.com node01'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop2
host_config='node02.kaikeba.com node02'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop3
host_config='node03.kaikeba.com node03'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"





####### hadoop2 #######


tar_container_name=hadoop2
host_name=node02.kaikeba.com
sudo docker exec -it ${tar_container_name} sh -c "echo ${host_name} > /etc/hostname"


###
src_container_name=hadoop1
host_config='node01.kaikeba.com node01'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop2
host_config='node02.kaikeba.com node02'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop3
host_config='node03.kaikeba.com node03'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"




####### hadoop3 #######


tar_container_name=hadoop3
host_name=node03.kaikeba.com
sudo docker exec -it ${tar_container_name} sh -c "echo ${host_name} > /etc/hostname"


###
src_container_name=hadoop1
host_config='node01.kaikeba.com node01'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop2
host_config='node02.kaikeba.com node02'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


###
src_container_name=hadoop3
host_config='node03.kaikeba.com node03'


container_ip=`sudo docker inspect ${src_container_name} | grep '\"IPAddress\"' | awk 'NR==1{print $2}' | sed 's/"//g' | sed 's/,//g'`
sudo docker exec -it ${tar_container_name} sh -c "echo ${container_ip} ${host_config} >> /etc/hosts"


