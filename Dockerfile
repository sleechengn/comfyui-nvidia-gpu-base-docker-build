FROM ubuntu:jammy

RUN apt update
RUN apt -y install openssh-server nano unzip wget curl psmisc net-tools git python3.11 python3-pip nginx fonts-noto-cjk-extra ffmpeg

# configure ssh-server
RUN sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN mkdir /run/sshd
RUN chmod -R 700 /run/sshd
RUN chown -R root /run/sshd
RUN echo "root:root" | chpasswd

# setup filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# configure
WORKDIR /opt
RUN git clone https://github.com/comfyanonymous/ComfyUI
WORKDIR /opt/ComfyUI
RUN python3.11 -m pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu121
WORKDIR /opt/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager
WORKDIR /opt/ComfyUI/custom_nodes/ComfyUI-Manager
RUN python3.11 -m pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu121

# clean cache
RUN ls -l

# configure filebrowser
RUN mkdir /opt/filebrowser

# ttyd
RUN apt install -y ttyd

#configure nginx
RUN rm -rf /etc/nginx/sites-enabled/*
ADD ./ComfyUI /etc/nginx/sites-enabled/

# setup and initialize
COPY ./init.sh /
RUN chmod +x /init.sh
COPY ./install.sh /
RUN chmod +x /install.sh

WORKDIR /opt/ComfyUI

ENTRYPOINT /init.sh

RUN python3.11 -m pip cache purge

VOLUME /opt/ComfyUI

RUN apt autoremove
