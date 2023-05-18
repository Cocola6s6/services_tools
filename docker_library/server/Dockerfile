FROM centos:centos7

#RUN groupadd -g  2023 cocola
#RUN useradd -u 1000 -g cocola -s /sbin/login cocolaServer100
RUN mkdir /home/cocolaServer -p

RUN yum install -y java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64

ARG workdir=/home/cocolaServer
VOLUME ${workdir}
WORKDIR ${workdir}
RUN cd /home/cocolaServer
ADD *.jar /home/cocolaServer/server.jar

EXPOSE 9091
RUN echo 'Asia/Shanghai' > /etc/timezone
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/urandom -Xms2048m -Xmx2048m -Xmn1024m -Xss256k -XX:PermSize=256m -XX:MaxPermSize=256m -XX:SurvivorRatio=8 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+UseCMSCompactAtFullCollection -XX:+CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=70 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/","-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5380","-jar","server.jar"]
