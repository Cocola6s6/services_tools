#!/bin/bash
set -e

cd /home/docker_library/server
rm -f *.jar
\cp /home/services_data/jenkins/jenkins_home/workspace/Gpt_First/Gpt_First/target/Gpt_First-0.0.1-SNAPSHOT.jar /home/docker_library/server
sh build.sh
cd /home/sys_install
sh install.sh ri server

