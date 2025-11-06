# from quay.io/openeuler/openeuler:22.03-lts-sp4
FROM quay.io/openeuler/openeuler:22.03-lts-sp4

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG USER=app
ARG GROUP=app
ARG UID=8888
ARG GID=8888
ARG APP_HOME=/data/app
ARG GOSU_URL=https://github.com/tianon/gosu/releases/download/1.19/gosu-amd64

# copy script
COPY docker-entrypoint.sh /

# install repositories and packages : curl bash bash-completion passwd openssl openssh wget net-tools gettext zip unzip ncurses ncurses-compat-libs fontconfig dos2unix glibc libgcc libstdc++ libuv tar util-linux findutils htop iotop iftop iperf3
RUN cp /etc/yum.repos.d/openEuler.repo /etc/yum.repos.d/openEuler.repo.backup && \
    sed -i "s#http://repo.openeuler.org#https://mirrors.aliyun.com/openeuler#g" /etc/yum.repos.d/openEuler.repo && \
    yum --disablerepo=debuginfo,source,update,update-source clean all && yum --disablerepo=debuginfo,source,update,update-source makecache && \
    yum --disablerepo=debuginfo,source,update,update-source install -y curl bash bash-completion passwd openssl openssh-server wget net-tools gettext zip unzip ncurses ncurses-compat-libs fontconfig dos2unix glibc libgcc libstdc++ libuv tar util-linux findutils htop iotop iftop iperf3 && \
    yum --disablerepo=debuginfo,source,update,update-source clean all && \rm -rf /var/lib/{cache,log} /var/log/lastlog && \
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
