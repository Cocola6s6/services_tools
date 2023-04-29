docker run -itd -v /home/docker-hub/data/registry:/var/lib/registry -p 5000:5000 -p 5001:8080 --restart=always --name registry registry:latest
