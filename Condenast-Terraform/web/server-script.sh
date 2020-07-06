#! /bin/bash
sudo apt-get update -y
sudo apt-get install docker-compose -y
sudo apt-get install python3-pip -y
sudo apt-get install git
git clone https://github.com/jitendar-singh/condenast.git && cd condenast
sudo docker-compose up --build

