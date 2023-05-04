#!/bin/bash

set -e

SYS_INSTALL_DIR=/home/sys_install
SERVICES_DATA_DIR=/home/services_data
DOCKER_LIBRARY_DIR=/home/docker_library
function createContainerAndRun(){
        docker-compose -f $SYS_INSTALL_DIR/docker-compose.yml up -d $1 
}

function buildAllImages(){
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

function prepareAllImages(){
	#loadAllImages
	buildAllImages
}

function installServer() {
	sh /home/sys-intstall/openPort.sh 9091
	createContainerAndRun server
}

function installAll(){
	echo $(date +'%Y-%m-%d %H:%M:%S'):"开始安装系统"
	prepareAllImages
	installServer
	echo $(date +'%Y-%m-%d %H:%M:%S'):"完成系统安装"
}

JENKINS_DATA_DIR=$SERVICES_DATA_DIR/jenkins
MAVEN_DATA_DIR=$SERVICES_DATA_DIR/jenkins/maven
JDK_DATA_DIR=$SERVICES_DATA_DIR/jenkins/jdk
function installJenkins(){
	if [ ! -d $JENKINS_DATA_DIR ]; then
		sudo mkdir $JENKINS_DATA_DIR -p
	fi
	cd $JENKINS_DATA_DIR

	if [ ! -d $MAVEN_DATA_DIR ]; then
		sudo mkdir $MAVEN_DATA_DIR

		if [ ! -f "apache-maven-3.6.3-bin.tar.gz"]; then
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
        fi
	
	if [ ! -d $JDK_DATA_DIR ]; then
		sudo mkdir $JDK_DATA_DIR

		if [ ! -f "jdk-8u371-linux-x64.tar.gz"]; then
			echo "===========>download jdk online"
			cd $JDK_DATA_DIR
			wget https://download.oracle.com/otn/java/jdk/8u371-b11/ce59cff5c23f4e2eaf4e778a117d4c5b/jdk-8u371-linux-x64.tar.gz
		else
			echo "===========>cp jdk"
			cp jdk-8u371-linux-x64.tar.gz $JDK_DATA_DIR
        	fi

		cd $JDK_DATA_DIR
		tar -zxvf jdk-8u371-linux-x64.tar.gz .
		mv jdk1.8.0_371 jdk
	fi

        chown -R 1000:1000 $SERVICES_DATA_DIR/jenkins
	chmod +777 $SERVICES_DATA_DIR/jenkins/*

	sh /home/sys_install/openPort.sh 9000
	systemctl restart docker
	createContainerAndRun jenkins
}

function stopAndRemoveContainer(){
        docker-compose stop $1
        docker-compose rm -f $1
}

function uninstallServer(){
	stopAndRemoveContainer server
}

function uninstallJenkins(){
	rm -rf $MAVEN_DATA_DIR
	#rm -rf $JDK_DATA_DIR
	stopAndRemoveContainer jenkins
}

function installSingle(){
        case $1 in
		mysql)
		        installServer
			;;
		nginx)
			installServer
			;;
	  	server)
      		        installServer
      		        ;;
		jenkins)
			installJenkins
			;;
                *)
                        ;;
        esac
}

function uninstallSingleAll(){
	case $1 in
		mysql)
			uninstallServer
			;;
		nginx)
			uninstallServer
			;;
	  	server)
      		        uninstallServer
      		        ;;
		jenkins)
			uninstallJenkins
			;;
                *)
                        ;;
        esac
}

function reinstallSingle(){
        uninstallSingleAll $1
        installSingle $1
}

case $1 in
	install-all)
		installAll
		;;
 	i)
    	        installSingle "$2"
		;;
	u)
		uninstallSingleAll "$2"
		;;
	ri)
		reinstallSingle "$2"
		;;
	*)
		echo "Usage: $0 [install|uninstall-all]"
		;;

esac