FROM centos:centos7

RUN mkdir -p /home/server
RUN yum install -y java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64

ARG workdir=/home/server
VOLUME ${workdir}
WORKDIR ${workdir}
RUN cd /home/server
ADD *.jar /home/server/server.jar

EXPOSE 9091
RUN echo 'Asia/Shanghai' > /etc/timezone
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/urandom -Xms2048m -Xmx2048m -Xmn1024m -Xss256k -XX:PermSize=256m -XX:MaxPermSize=256m -XX:SurvivorRatio=8 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+UseCMSCompactAtFullCollection -XX:+CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=70 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/","-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5380","-jar","server.jar"]
