FROM ubuntu:22.04
ENV container=docker

RUN apt-get update && \
    apt-get install -y systemd openssh-server sudo python3 passwd && \
    apt-get clean

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do \
      [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev* \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/*

RUN mkdir /var/run/sshd && \
    ssh-keygen -A && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/^UsePAM no$/#UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd

RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible && \
    mkdir -p /home/ansible/.ansible && \
    mkdir -p /home/ansible/.ansible/tmp && \
    chown -R ansible:ansible /home/ansible/.ansible

# Enable systemd-user-sessions to permit non-root logins after boot
RUN ln -sf /lib/systemd/system/systemd-user-sessions.service \
        /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service

# Enable SSH service (this was missing!)
RUN systemctl enable ssh.service

VOLUME ["/sys/fs/cgroup"]
EXPOSE 22
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]