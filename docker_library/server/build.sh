set -e
echo "start build"
sudo docker build --network=host -t server:1.0 . --network=host
