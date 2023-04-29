systemctl start firewalld
firewall-cmd --zone=public --add-port=$1/tcp --permanent
systemctl restart firewalld
