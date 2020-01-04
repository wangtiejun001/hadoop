# 大数据课程软件统一说明

centos version: 7.6.1810

### build base centos7.6.1810 base image:
> files needed:
> jdk-8u161-linux-x64.tar.gz
> hadoop-2.6.0-cdh5.14.2_after_compile.tar.gz
> public_key_gen.sh

- public_key_gen.sh
```bash
#!/bin/bash
runuser -l hadoop -c "ssh-keygen -q -t rsa -N '' -f /home/hadoop/.ssh/id_rsa"
```

- Dockerfile
```Dockerfile
FROM scratch
# https://raw.githubusercontent.com/CentOS/sig-cloud-instance-images/7c2e214edced0b2f22e663ab4175a80fc93acaa9/docker/centos-7-docker.tar.xz
ADD centos-7-docker.tar.xz /

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="CentOS Base Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20181204"

CMD ["/bin/bash"]
```

- Build
```bash
sudo docker build -t centos7.6.1810 .
```


### build hadoop base image
- Dockerfile
```Dockerfile
FROM centos7.6.1810
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

## enable ssh
RUN yum -y install openssl openssh-server openssh-clients

## enable commands: service
RUN yum install initscripts -y

## install common tools:
RUN yum install -y vim
RUN yum install -y wget
RUN yum -y install openssl-devel

RUN yum -y install autoconf automake libtool cmake
RUN yum -y install ncurses-devel
RUN yum -y install openssl-devel
RUN yum -y install lzo-devel zlib-devel gcc gcc-c++

RUN yum install -y  bzip2-devel

## users and passwords
RUN yum install -y sudo
RUN echo "root:root" | chpasswd
RUN useradd -ms /bin/bash hadoop
RUN echo 'hadoop:123456' | chpasswd
RUN echo 'hadoop    ALL=(ALL)   ALL' >> /etc/sudoers


## prepare directories:
RUN mkdir -p /kkb/soft
RUN mkdir -p /kkb/install
RUN chown -R hadoop:hadoop /kkb

## keep time update with aliyun
RUN yum install -y crontabs
RUN yum -y install ntpdate
RUN touch /etc/cron.d/time_update
RUN echo '*/1 * * * * /usr/sbin/ntpdate time1.aliyun.com' > /etc/cron.d/time_update
RUN chmod 0644 /etc/cron.d/time_update
# APPLY CRON TAB
RUN crontab /etc/cron.d/time_update

ADD jdk-8u161-linux-x64.tar.gz /kkb/install
ENV JAVA_HOME /kkb/install/jdk1.8.0_161
ENV PATH=$JAVA_HOME/bin:$PATH
RUN echo $PATH
RUN java -version


RUN yum -y install openssl-devel


# add hadoop after compile
ADD hadoop-2.6.0-cdh5.14.2_after_compile.tar.gz /kkb/install

RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/tempDatas
RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/namenodeDatas
RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/datanodeDatas
RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/edits
RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/snn/name
RUN mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/snn/edits

RUN chown -R hadoop:hadoop /kkb

ADD public_key_gen.sh /tmp

# ensble login
RUN rm -f /run/nologin

VOLUME [ "/sys/fs/cgroup" ]

## effect: systemctl
CMD ["/usr/sbin/init"]

```

- Build
```bash
container_tag=v0.93
sudo docker build --rm -t local/centos-systemd:${container_tag} .
```

#### start hadoop docker instance
- Start hadoop1
```bash
container_name=hadoop1

sudo docker run -d \
--name ${container_name} \
-p 50070:50070 \
-p 8088:8088 \
-p 19888:19888 \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}
```

- Start hadoop2
```bash
container_name=hadoop2

sudo docker run -d \
--name ${container_name} \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}
```

- Start hadoop3
```bash
container_name=hadoop3

sudo docker run -d \
--name ${container_name} \
--tmpfs /run \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
local/centos-systemd:${container_tag}
```





### 三台机器分别更改主机名

第一台主机名更改为：node01.kaikeba.com

第二台主机名更改为：node02.kaikeba.com

第三台主机名更改为：node03.kaikeba.com

run following on host machine

- config-hosts.sh
```bash
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

```


## 五、三台机器安装zookeeper集群

注意事项：==三台机器一定要保证时钟同步==

### 第一步：下载zookeeeper的压缩包，下载网址如下

http://archive.cloudera.com/cdh5/cdh/5/

我们在这个网址下载我们使用的zk版本为[zookeeper-3.4.5-cdh5.14.2.tar.gz](http://archive.cloudera.com/cdh5/cdh/5/zookeeper-3.4.5-cdh5.14.2.tar.gz)

下载完成之后，上传到我们的node01的/kkb/soft路径下准备进行安装

### 第二步：解压

node01执行以下命令解压zookeeper的压缩包到node01服务器的/kkb/install路径下去，然后准备进行安装

```
cd /kkb/soft

tar -zxvf zookeeper-3.4.5-cdh5.14.2.tar.gz  -C /kkb/install/
```



### 第三步：修改配置文件

第一台机器修改配置文件

```
cd /kkb/install/zookeeper-3.4.5-cdh5.14.2/conf

cp zoo_sample.cfg zoo.cfg

mkdir -p /kkb/install/zookeeper-3.4.5-cdh5.14.2/zkdatas

vim  zoo.cfg
dataDir=/kkb/install/zookeeper-3.4.5-cdh5.14.2/zkdatas
autopurge.snapRetainCount=3
autopurge.purgeInterval=1

server.1=node01:2888:3888
server.2=node02:2888:3888
server.3=node03:2888:3888
```

 

### 第四步：添加myid配置

在第一台机器的/kkb/install/zookeeper-3.4.5-cdh5.14.2/zkdatas/

这个路径下创建一个文件，文件名为myid ,文件内容为1

```
echo 1 > /kkb/install/zookeeper-3.4.5-cdh5.14.2/zkdatas/myid
```

 

### 第五步：安装包分发并修改myid的值

安装包分发到其他机器

```
第一台机器上面执行以下两个命令

scp -r /kkb/install/zookeeper-3.4.5-cdh5.14.2/ node02:/kkb/install/

scp -r /kkb/install/zookeeper-3.4.5-cdh5.14.2/ node03:/kkb/install/

第二台机器上修改myid的值为2

直接在第二台机器任意路径执行以下命令

echo 2 > /kkb/install/zookeeper-3.4.5-cdh5.14.2/myid

 

第三台机器上修改myid的值为3

直接在第三台机器任意路径执行以下命令

echo 3 > /kkb/install/zookeeper-3.4.5-cdh5.14.2/myid
```

 

### 第六步：三台机器启动zookeeper服务

三台机器启动zookeeper服务

这个命令三台机器都要执行

```
/kkb/install/zookeeper-3.4.5-cdh5.14.2/bin/zkServer.sh start

查看启动状态

/kkb/install/zookeeper-3.4.5-cdh5.14.2/bin/zkServer.sh status
```


 

### 2、hadoop集群的安装

   安装环境服务部署规划

| 服务器IP       | 192.168.52.100    | 192.168.52.110 | 192.168.52.120 |
| -------------- | ----------------- | -------------- | -------------- |
| HDFS           | NameNode          |                |                |
| HDFS           | SecondaryNameNode |                |                |
| HDFS           | DataNode          | DataNode       | DataNode       |
| YARN           | ResourceManager   |                |                |
| YARN           | NodeManager       | NodeManager    | NodeManager    |
| 历史日志服务器 | JobHistoryServer  |                |                |

#### 第一步：上传压缩包并解压

将我们重新编译之后支持snappy压缩的hadoop包上传到第一台服务器并解压

第一台机器执行以下命令

```
cd /kkb/soft/



tar -zxvf hadoop-2.6.0-cdh5.14.2_after_compile.tar.gz -C ../install/
```

 

#### 第二步：查看hadoop支持的压缩方式以及本地库

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2

bin/hadoop checknative
```

​                                                  

如果出现openssl为false，那么所有机器在线安装openssl即可，执行以下命令，虚拟机联网之后就可以在线进行安装了

```
yum -y install openssl-devel
```

 

#### 第三步：修改配置文件

##### 修改core-site.xml

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim core-site.xml

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://node01:8020</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/tempDatas</value>
    </property>
    <!--  缓冲区大小，实际工作中根据服务器性能动态调整 -->
    <property>
        <name>io.file.buffer.size</name>
        <value>4096</value>
    </property>
    <!--  开启hdfs的垃圾桶机制，删除掉的数据可以从垃圾桶中回收，单位分钟 -->
    <property>
        <name>fs.trash.interval</name>
        <value>10080</value>
    </property>
</configuration>
```

 

##### 修改hdfs-site.xml

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim hdfs-site.xml

<configuration>
    <!-- NameNode存储元数据信息的路径，实际工作中，一般先确定磁盘的挂载目录，然后多个目录用，进行分割   --> 
    <!--   集群动态上下线 
    <property>
        <name>dfs.hosts</name>
        <value>/kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop/accept_host</value>
    </property>
    <property>
        <name>dfs.hosts.exclude</name>
        <value>/kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop/deny_host</value>
    </property>
     -->
     <property>
            <name>dfs.namenode.secondary.http-address</name>
            <value>node01:50090</value>
    </property>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>node01:50070</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/namenodeDatas</value>
    </property>
    <!--  定义dataNode数据存储的节点位置，实际工作中，一般先确定磁盘的挂载目录，然后多个目录用，进行分割  -->
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/datanodeDatas</value>
    </property>
    <property>
        <name>dfs.namenode.edits.dir</name>
        <value>file:///kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/edits</value>
    </property>
    <property>
        <name>dfs.namenode.checkpoint.dir</name>
        <value>file:///kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/snn/name</value>
    </property>
    <property>
        <name>dfs.namenode.checkpoint.edits.dir</name>
        <value>file:///kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/snn/edits</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
<property>
        <name>dfs.blocksize</name>
        <value>134217728</value>
    </property>
</configuration>

```

 

##### 修改hadoop-env.sh

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim hadoop-env.sh
export JAVA_HOME=/kkb/install/jdk1.8.0_161

```



##### 修改mapred-site.xml

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim mapred-site.xml

<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.job.ubertask.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>node01:10020</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>node01:19888</value>
    </property>
</configuration>

```

 

 

##### 修改yarn-site.xml

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim yarn-site.xml

<configuration>
    <property>
       <name>yarn.resourcemanager.hostname</name>
        <value>node01</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>

```

 

##### 修改slaves文件

第一台机器执行以下命令

```
cd /kkb/install/hadoop-2.6.0-cdh5.14.2/etc/hadoop

vim slaves


node01
node02
node03

```



#### 第四步：创建文件存放目录

第一台机器执行以下命令

node01机器上面创建以下目录

```
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/tempDatas
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/namenodeDatas
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/datanodeDatas 
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/edits
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/snn/name
mkdir -p /kkb/install/hadoop-2.6.0-cdh5.14.2/hadoopDatas/dfs/nn/snn/edits
```

#### 第五步：安装包的分发

第一台机器执行以下命令

```
cd /kkb/install/

scp -r hadoop-2.6.0-cdh5.14.2/ node02:$PWD
scp -r hadoop-2.6.0-cdh5.14.2/ node03:$PWD

```



#### 第六步：配置hadoop的环境变量

三台机器都要进行配置hadoop的环境变量

三台机器执行以下命令

```
vim  /etc/profile

export HADOOP_HOME=/kkb/install/hadoop-2.6.0-cdh5.14.2
export PATH=:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

配置完成之后生效

source /etc/profile

```



#### 第七步：集群启动

要启动 Hadoop 集群，需要启动 HDFS 和 YARN 两个集群。 

注意：首次启动HDFS时，必须对其进行格式化操作。本质上是一些清理和准备工作，因为此时的 HDFS 在物理上还是不存在的。

```
bin/hdfs namenode  -format或者bin/hadoop namenode –format
```



##### 单个节点逐一启动

```
在主节点上使用以下命令启动 HDFS NameNode： 
hadoop-daemon.sh start namenode 

在每个从节点上使用以下命令启动 HDFS DataNode： 
hadoop-daemon.sh start datanode 

在主节点上使用以下命令启动 YARN ResourceManager： 
yarn-daemon.sh  start resourcemanager 

在每个从节点上使用以下命令启动 YARN nodemanager： 
yarn-daemon.sh start nodemanager 

以上脚本位于$HADOOP_PREFIX/sbin/目录下。如果想要停止某个节点上某个角色，只需要把命令中的start 改为stop 即可。

```



##### 脚本一键启动 

如果配置了 etc/hadoop/slaves 和 ssh 免密登录，则可以使用程序脚本启动所有Hadoop 两个集群的相关进程，在主节点所设定的机器上执行。

启动集群

node01节点上执行以下命令

```
第一台机器执行以下命令

cd /kkb/install/hadoop-2.6.0-cdh5.14.2/
sbin/start-dfs.sh
sbin/start-yarn.sh
sbin/mr-jobhistory-daemon.sh start historyserver

停止集群：

sbin/stop-dfs.sh

sbin/stop-yarn.sh

```

 

#### 第八步：浏览器查看启动页面

hdfs集群访问地址

http://192.168.52.100:50070/dfshealth.html#tab-overview  

yarn集群访问地址

http://192.168.52.100:8088/cluster

jobhistory访问地址：

http://192.168.52.100:19888/jobhistory

 













 

 

 

 

 







































