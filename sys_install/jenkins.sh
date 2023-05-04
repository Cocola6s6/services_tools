#!/bin/bash
set -e
echo “==========>开始构建”
\cp /home/sys-install/config/jenkins/jenkins_home/workspace/Gpt_First/Gpt_First/target/Gpt_First-0.0.1-SNAPSHOT.jar /home/docker-library/server
cd /home/docker-library/server
sh build.sh
cd /home/sys-install
sh install.sh ri server
echo "==========>结束构建"
