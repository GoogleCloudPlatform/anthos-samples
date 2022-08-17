FROM ubuntu:20.04

# Dependencies
# - ENV variables

ENV DEBIAN_FRONTEND=noninteractive
ARG GCLOUD_VERSION="384.0.0"

RUN apt-get update && apt-get -y upgrade

# Setup Date/Time to UTC
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get install -y --no-install-recommends tzdata
#install dependencies...
RUN apt-get install -y apt-utils vim nano python3-pip python-is-python3 curl wget openssh-server cron gettext iputils-ping direnv

RUN mkdir -p /tmp/gcloud-install \
    && mkdir -p /var/gcloud-sdk \
    && curl --output /tmp/gcloud-install/gcloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
    && tar -xvf /tmp/gcloud-install/gcloud-sdk.tar.gz -C /var/gcloud-sdk \
    && rm -rf /tmp/gcloud-install

# Auto-update upon building
RUN /var/gcloud-sdk/google-cloud-sdk/bin/gcloud components update --quiet --verbosity=critical --no-user-output-enabled

# Setup CRON for configuration drift script
COPY docker-config-drift.cron /etc/cron.d/docker-config-drift
RUN chmod 0744 /etc/cron.d/docker-config-drift
RUN crontab /etc/cron.d/docker-config-drift
RUN touch /var/log/cron.log

# Add gcloud to bashrc (for the current/root user)
RUN printf '\n#gcloud binaries\nexport PATH=/var/gcloud-sdk/google-cloud-sdk/bin:${PATH}\n' >> ~/.bashrc

# add authentication for gcloud when bash starts up
RUN printf '\n#gcloud authentication\n[ ! -z "${PROJECT_ID}" ] && gcloud auth activate-service-account --key-file=./build-artifacts/consumer-edge-gsa.json --project ${PROJECT_ID}' >> ~/.bashrc

# Add SSH Config to avoid fingerprint checking
RUN mkdir -p ~/.ssh && touch ~/.ssh/config
RUN printf 'Host *\n\tStrictHostKeyChecking no\n' >> ~/.ssh/config
RUN chmod 600 ~/.ssh/config

#direnv installed above via apt
RUN printf '\n#direnv hook\neval "$(direnv hook bash)"\n' >> ~/.bashrc

# Configure touch points
RUN mkdir -p /var/consumer-edge-install

VOLUME [ "/var/consumer-edge-install" ]

# Setup Ansible and other PIP-based dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

WORKDIR /var/consumer-edge-install

# Run a startup script on start so-as to auto-populate functionality from dynamically added volume
CMD direnv allow . \
    && export PATH=/var/gcloud-sdk/google-cloud-sdk/bin:${PATH} \
    && gcloud auth activate-service-account --key-file=./build-artifacts/consumer-edge-gsa.json --project ${PROJECT_ID} \
    && cron \
    && gcloud auth configure-docker --quiet --verbosity=critical \
    && /bin/bash
