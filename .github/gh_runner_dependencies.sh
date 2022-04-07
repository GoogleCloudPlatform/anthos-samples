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

# shellcheck disable=SC1090
cd "$HOME" || exit
sudo apt-get install -y \
  curl \
  wget \
  vim \
  git \
  unzip \
  gcc \
  ca-certificates \
  gnupg \
  lsb-release

# install Golang
wget "https://dl.google.com/go/$(curl https://golang.org/VERSION?m=text).linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go*
sudo chown -R root:root ./go
sudo mv go /usr/local
echo "export GOPATH=$HOME/go" >> "$HOME"/.profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> "$HOME"/.profile
source "$HOME"/.profile

# install the addlicense tool used to check files for license headers
go get -u github.com/google/addlicense
sudo ln -s "$HOME"/go/bin/addlicense /bin

# install the tfenv tool to manage terraform versions
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s "$HOME"/.tfenv/bin/* /bin

# install the terraform versions and configure it to the latest
tfenv install 1.0.0
tfenv install 1.0.1
tfenv install 1.0.6
tfenv install 1.1.3
tfenv use 1.1.3

# install the golint binary
go get -u golang.org/x/lint/golint
sudo ln -s "$HOME"/go/bin/golint /bin/

# install docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker "${USER}"

# create the local directory used by the github actions runner
sudo mkdir -p /var/local/gh-runner

echo "All dependencies have been installed."
echo "You have to download the Service Account key into this host, store it under /var/local/gh-runner and give it 444 permissions"
echo "
  > gcloud auth login
  > PROJECT_ID=anthos-gke-samples-ci
  > SERVICE_ACCOUNT_NAME=gh-actions-anthos-samples-sa
  > gcloud iam service-accounts keys create sa-key.json --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
  > sudo mv ./sa-key.json /var/local/gh-runner/
  > sudo chmod 444 /var/local/gh-runner/sa-key.json
  > sudo bash -c 'echo export GOOGLE_APPLICATION_CREDENTIALS=/var/local/gh-runner/sa-key.json > /var/local/gh-runner/env_vars'
  > sudo bash -c 'echo export GOOGLE_CLOUD_PROJECT=anthos-gke-samples-ci >> /var/local/gh-runner/env_vars'
"
