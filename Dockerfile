# syntax=docker/dockerfile:1
#FROM alpine:3.14
FROM ubuntu:22.04
#WORKDIR /code
ENV TZ="Europe/Paris"


RUN apt update -y
RUN apt upgrade -y
RUN apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
RUN apt install -y --no-install-recommends git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler wget \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 \
    udev


RUN pip3 install --user -U west

ENV PATH="/root/.local/bin:$PATH"

RUN west init /zephyrproject

WORKDIR /zephyrproject

RUN west update 
RUN west zephyr-export

RUN pip3 install --user -r /zephyrproject/zephyr/scripts/requirements.txt
WORKDIR /
RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/zephyr-sdk-0.15.2_linux-x86_64.tar.gz 
RUN wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/sha256.sum | shasum --check --ignore-missing 
RUN tar xvf zephyr-sdk-0.15.2_linux-x86_64.tar.gz
    
WORKDIR /zephyr-sdk-0.15.2
RUN yes | ./setup.sh

#RUN mkdir /etc/udev/
#RUN cp /zephyr-sdk-0.15.2/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
#RUN udevadm control --reload 

#COPY . .
WORKDIR /zephyrproject

#CMD echo "Hello World"