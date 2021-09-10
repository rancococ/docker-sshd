# docker-sshd

#### 项目介绍
docker-sshd

support os:
1. alpine:curl bash openssh wget net-tools gettext zip unzip tzdata ncurses
2. centos:passwd openssl openssh-server wget net-tools gettext zip unzip ncurses

support tool
1. sshd
2. apphome: /data/app
3. user: root/admin; app/123456
4. usage:
docker run -it --rm --name sshd-alpine registry.cn-hangzhou.aliyuncs.com/rancococ/sshd:alpine "bash"
docker run -it --rm --name sshd-centos registry.cn-hangzhou.aliyuncs.com/rancococ/sshd:centos "bash"
