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


# install jdk
#ADD jdk-8u161-linux-x64.tar.gz /kkb/soft
#ENV JAVA_HOME /kkb/soft/jdk1.8.0_161
#ENV PATH=$JAVA_HOME/bin:$PATH
#RUN echo $PATH
#RUN java -version

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
