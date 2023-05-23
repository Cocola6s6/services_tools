set -e
sudo docker build -t server:1.0 . --network=host
