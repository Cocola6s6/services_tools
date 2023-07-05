#!/bin/bash
set -e

## 开放端口
function openPort() {
	#systemctl start firewalld
	firewall-cmd --zone=public --add-port=$1/tcp
	firewall-cmd --list-ports
	#systemctl restart firewalld	
}

## 创建docker容器并启动
SYS_INSTALL_DIR=/home/sys_install
SERVICES_DATA_DIR=/home/services_data
DOCKER_LIBRARY_DIR=/home/docker_library
function createContainerAndRun(){
        docker-compose -f $SYS_INSTALL_DIR/docker-compose.yml up -d $1 
}

## 构建docker镜像
function buildAllImages() {
        for file in ${DOCKER_LIBRARY_DIR}/*;
        do
                echo $file
		if [ ! -d $file ]; then
			continue
		fi

                cd $file
                sh build.sh
        done
	cd "$SYS_INSTALL_DIR" 
}

## 准备docker镜像
function prepareAllImages() {
	#loadAllImages
	buildAllImages
}

## 安装server服务
function installServer() {
	createContainerAndRun server
}

## 安装elasticsearch服务
ELA_DATA_DIR=$SERVICES_DATA_DIR/elasticsearch/data
ELA_PLUG_DIR=$SERVICES_DATA_DIR/elasticsearch/plugins
function installEla() {
	if [ ! -d $ELA_DATA_DIR ]; then
                sudo mkdir $ELA_DATA_DIR -p
        fi
	
	if [ ! -d $ELA_PLUG_DIR ]; then
                sudo mkdir $ELA_PLUG_DIR -p
        fi
	chmod +777 $ELA_DATA_DIR
	
	cd "$SYS_INSTALL_DIR"
	openPort 9200
	openPort 9300
	
	createContainerAndRun elasticsearch
}

## 安装kibbna服务
function installKibana() {
        cd "$SYS_INSTALL_DIR"
        openPort 5601       
 
        createContainerAndRun kibana
}

## 安装logstash服务
function installLogstash() {
        cd "$SYS_INSTALL_DIR" 	
        openPort 5407
        openPort 9600

        createContainerAndRun logstash
}

## 安装kafka服务
function installKafka() {
        cd "$SYS_INSTALL_DIR"
	openPort 9092
	openPort 9093

        createContainerAndRun kafka
	sleep 10
	createKafkaTopics
}

## 创建kafka主题
KAFKA_TOPIC_ARRAY=(
	log-topic
)

function createKafkaTopics() {
	echo "开始创建kafka主题"
	for(( i=0;i<${#KAFKA_TOPIC_ARRAY[@]};i++)) do
		sudo docker exec -it kafka /bin/bash -c "/opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic ${KAFKA_TOPIC_ARRAY[$i]}"
	done;

	echo "结束创建kafka主题"
}

## 安装nginx服务
function installNginx() {
        cd "$SYS_INSTALL_DIR"
        openPort 80
        openPort 443

        createContainerAndRun nginx
}

## 安装postgres服务
POSTGRES_DATA_DIR=$SERVICES_DATA_DIR/postgres
function installPostgres() {
	if [ ! -d $POSTGRES_DATA_DIR ]; then
                sudo mkdir $POSTGRES_DATA_DIR -p
        fi
        cd $POSTGRES_DATA_DIR	

	openPort 15432
	createContainerAndRun postgres
}

## 安装jenkins服务
JENKINS_DATA_DIR=$SERVICES_DATA_DIR/jenkins
MAVEN_DATA_DIR=$SERVICES_DATA_DIR/jenkins/maven
JDK_DATA_DIR=$SERVICES_DATA_DIR/jenkins/jdk
function installJenkins() {
	if [ ! -d $JENKINS_DATA_DIR ]; then
		sudo mkdir $JENKINS_DATA_DIR -p
	fi
	cd $JENKINS_DATA_DIR

	if [ ! -d $MAVEN_DATA_DIR ]; then
		sudo mkdir $MAVEN_DATA_DIR

		if [ ! -f "apache-maven-3.6.3-bin.tar.gz" ]; then
                        echo "===========>download maven online"
                        cd $MAVEN_DATA_DIR
			wget https://mirrors.aliyun.com/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
                else 
                        echo "===========>cp maven"
                        cp apache-maven-3.6.3-bin.tar.gz $MAVEN_DATA_DIR
                fi

		cd $MAVEN_DATA_DIR
                tar -zxvf apache-maven-3.6.3-bin.tar.gz
		mv apache-maven-3.6.3 maven
		cd $JENKINS_DATA_DIR
        fi
	
	if [ ! -d $JDK_DATA_DIR ]; then
		sudo mkdir $JDK_DATA_DIR

		if [ ! -f "jdk-8u371-linux-x64.tar.gz" ]; then
			echo "===========>download jdk online"
			cd $JDK_DATA_DIR
			#wget https://download.oracle.com/otn/java/jdk/8u371-b11/ce59cff5c23f4e2eaf4e778a117d4c5b/jdk-8u371-linux-x64.tar.gz
		else
			echo "===========>cp jdk"
			cp jdk-8u371-linux-x64.tar.gz $JDK_DATA_DIR
        	fi

		cd $JDK_DATA_DIR
		tar -zxvf jdk-8u371-linux-x64.tar.gz
		mv jdk1.8.0_371 jdk
		cd $JENKINS_DATA_DIR
	fi

        chown -R 1000:1000 $SERVICES_DATA_DIR/jenkins
	chmod +777 $SERVICES_DATA_DIR/jenkins/*

	sh /home/sys_install/openPort.sh 9000
	createContainerAndRun jenkins
}

## 安装全部服务
function installAll() {
	echo $(date +'%Y-%m-%d %H:%M:%S'):"开始安装系统"
	prepareAllImages
	installEla
	installKibana
	installLogstash
	installKafka
	#installNginx
	#installPostgres
	installServer
	echo $(date +'%Y-%m-%d %H:%M:%S'):"完成系统安装"
}


## 停止并删除容器
function stopAndRemoveContainer() {
        docker-compose stop $1
        docker-compose rm -f $1
}

## 取消安装server服务 
function uninstallServer() {
	stopAndRemoveContainer server
}

## 取消安装ela服务
function uninstallEla() {
	rm -rf $ELA_DATA_DIR
	rm -rf $ELA_PLUG_DIR
	stopAndRemoveContainer elasticsearch
}

## 取消安装kibana服务
function uninstallKibana() {
	stopAndRemoveContainer kibana
}

## 取消安装logstash服务
function uninstallLogstash() {
        stopAndRemoveContainer logstash
}

## delete kafka主题
function deleteKafkaTopics() {
        echo "开始delete kafka主题"
        for(( i=0;i<${#KAFKA_TOPIC_ARRAY[@]};i++)) do
                sudo docker exec -it kafka /bin/bash -c "/opt/kafka/bin/kafka-topics.sh --delete --zookeeper zookeeper:2181 --topic ${KAFKA_TOPIC_ARRAY[$i]}"
        done;
             
        echo "结束delete kafka主题"
}

## 取消安装kafka服务
function uninstallKafka() {
	#deleteKafkaTopics
	stopAndRemoveContainer zookeeper
        stopAndRemoveContainer kafka
}

## 取消安装nginx服务
function uninstallNginx() {
        stopAndRemoveContainer nginx
}

## 取消安装postgres服务
function uninstallPostgres() {
	stopAndRemoveContainer postgres
}

## 取消安装jenkins服务
function uninstallJenkins() {
	rm -rf $MAVEN_DATA_DIR
	rm -rf $JDK_DATA_DIR
	stopAndRemoveContainer jenkins
}

## 安装单个服务
function installSingle() {
        case $1 in
		elasticsearch)
		        installEla
			;;
		kibana)
			installKibana
			;;
	  	logstash)
      		        installLogstash
      		        ;;
		server)
			installServer
			;;
		kafka)
                        installKafka
                        ;;
		nginx)
                        installNginx
                        ;;
		postgres)
			installPostgres
			;;
		jenkins)
                        installJenkins
			;;
		topic)
			createKafkaTopics
			;;
                *)
                        ;;
        esac
}

## 取消安装单个服务
function uninstallSingle() {
	case $1 in
		elasticsearch)
			uninstallEla
			;;
		kibana)
			uninstallKibana
			;;
	  	logstash)
      		        uninstallLogstash
      		        ;;
		server)
			uninstallServer
			;;
                kafka)
                        uninstallKafka
                        ;;
                nginx)
                        uninstallNginx
			;;
		postgres)
			uninstallPostgres
			;;
		jenkins) 
                        uninstallJenkins
                        ;;
		topic)
			deleteKafkaTopics
			;;
                *)
                        ;;
        esac
}

## 重新安装单个服务
function reinstallSingle() {
        uninstallSingle $1
        installSingle $1
}

## 选择功能
case $1 in
	all)
		installAll
		;;
 	i)
    	        installSingle "$2"
		;;
	u)
		uninstallSingle "$2"
		;;
	ri)
		reinstallSingle "$2"
		;;
	port)
		openPort "$2"
		;;
	*)
		echo "Usage: $0 [all|i]"
		;;

esac
