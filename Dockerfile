# from registry.cn-hangzhou.aliyuncs.com/rancococ/centos:7-utf8
FROM registry.cn-hangzhou.aliyuncs.com/rancococ/centos:7-utf8

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG CENTOS_VER=7
ARG USER=app
ARG GROUP=app
ARG UID=8888
ARG GID=8888
ARG APP_HOME=/data/app
ARG GOSU_URL=https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64

# copy script
COPY docker-entrypoint.sh /

# install repositories and packages : curl bash bash-completion passwd openssl openssh wget net-tools gettext zip unzip ncurses fontconfig
RUN \rm -rf /etc/yum.repos.d/*.repo && \
    curl -s -o /etc/yum.repos.d/centos.repo http://mirrors.aliyun.com/repo/Centos-${CENTOS_VER}.repo && \
    curl -s -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${CENTOS_VER}.repo && \
    sed -i '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
    sed -i '/mirrors.cloud.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
    yum clean all && yum makecache && \
    \rm -rf /etc/pki/rpm-gpg/* && \
    curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER} https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${CENTOS_VER} && \
    curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${CENTOS_VER} https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${CENTOS_VER} && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER} && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${CENTOS_VER} && \
    sed -i 's@override_install_langs=en_US.utf8@#override_install_langs=en_US.utf8@g' "/etc/yum.conf" && \
    yum install -y curl bash bash-completion passwd openssl openssh-server wget net-tools gettext zip unzip ncurses fontconfig && \
    yum reinstall -y glibc-common && \
    yum clean all && \rm -rf /var/lib/{cache,log} /var/log/lastlog && \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config && \
    sed -i '/^session\s\+required\s\+pam_loginuid.so/s/^/#/' /etc/pam.d/sshd && \
    echo "Asia/Shanghai" > /etc/timezone && \ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    touch /home/.bashrc && \
    echo "export HISTTIMEFORMAT=\"%d/%m/%y %T \"" >> /home/.bashrc && \
    echo "export PS1='[\u@\h \W]\$ '" >> /home/.bashrc && \
    echo "alias ll='ls -al'" >> /home/.bashrc && \
    echo "alias ls='ls --color=auto'" >> /home/.bashrc && \
    chmod +x /home/.bashrc && \
    mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh && echo 'admin' | passwd --stdin root && \
    mkdir -p ${APP_HOME} && \
    groupadd -r -g ${GID} ${GROUP} && \
    useradd -r -m -g ${GROUP} -d ${APP_HOME} -u ${UID} -s /bin/bash ${USER} && echo '123456' | passwd --stdin ${USER} && \
    \cp /home/.bashrc ${APP_HOME} && \
    chown -R ${UID}:${GID} ${APP_HOME}/.bashrc && \
    wget -c -O /usr/local/bin/gosu --no-cookies --no-check-certificate "${GOSU_URL}" && chmod +x /usr/local/bin/gosu && \
    chown -R ${USER}:${GROUP} /data && \
    chown -R ${USER}:${GROUP} /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# set environment
ENV LANG zh_CN.UTF-8
ENV TZ "Asia/Shanghai"
ENV TERM xterm
ENV PATH .:${PATH}

# set work home
WORKDIR /data

# expose port 22
EXPOSE 22

# stop signal
STOPSIGNAL SIGTERM

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]

# default command
CMD [""]
