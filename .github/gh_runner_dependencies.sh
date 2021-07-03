#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


cd "$HOME" || exit
sudo apt-get install -y curl wget vim git unzip gcc

wget "https://dl.google.com/go/$(curl https://golang.org/VERSION?m=text).linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go*
sudo chown -R root:root ./go
sudo mv go /usr/local
echo "export GOPATH=$HOME/go" >> "$HOME"/.profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> "$HOME"/.profile
# shellcheck source="$HOME"/.profile
. "$HOME"/.profile

go get -u github.com/google/addlicense
sudo ln -s "$HOME"/go/bin/addlicense /bin

git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s "$HOME"/.tfenv/bin/* /bin

tfenv install 0.14.9
tfenv install 0.15.5
tfenv install 1.0.0
tfenv install 1.0.1

tfenv use 0.14.9

go get -u golang.org/x/lint/golint
sudo ln -s "$HOME"/go/bin/golint /bin/
