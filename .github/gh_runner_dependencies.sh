#!/bin/bash

cd $HOME
sudo apt-get install -y curl wget vim git unzip

wget "https://dl.google.com/go/$(curl https://golang.org/VERSION?m=text).linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go*
sudo chown -R root:root ./go
sudo mv go /usr/local
echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.profile
source ~/.profile

go get -u github.com/google/addlicense
sudo ln -s $HOME/go/bin/addlicense /bin

sudo git clone https://github.com/tfutils/tfenv.git /root/.tfenv
sudo ln -s /root/.tfenv/bin/tfenv /bin

tfenv install 0.14.9
tfenv install 0.15.5
tfenv install 1.0.0

tfenv use 0.14.9