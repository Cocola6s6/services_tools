#!/bin/bash

set -e

function createContainerAndRun(){
        docker-compose -f docker-compose.yml up -d $1 
}

DOCKER_LIBRARY_DIR=/home/docker-library
SYS_INSTALL_DIR=/home/sys-install
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
	createContainerAndRun server
}

function installAll(){
	echo $(date +'%Y-%m-%d %H:%M:%S'):"开始安装系统"
	prepareAllImages
	installServer
	echo $(date +'%Y-%m-%d %H:%M:%S'):"完成系统安装"
}

function stopAndRemoveContainer()
{
        docker-compose stop $1
        docker-compose rm -f $1
}

function uninstallServer()
{
	stopAndRemoveContainer server
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
