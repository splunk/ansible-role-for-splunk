FROM almalinux:9
ENV container=docker

RUN dnf -y install systemd systemd-sysv openssh-server sudo python3 passwd authselect ethtool && \
    dnf clean all

# Fix nsswitch.conf to prioritize local files over sss for user/group lookups
# This prevents PAM account phase failures when sssd is not running.
RUN sed -i -e 's/^\(passwd:\s*\)sss files/\1files sss/' \
           -e 's/^\(group:\s*\)sss files/\1files sss/' /etc/nsswitch.conf

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do \
      [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev* \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/*

# Set up SSH server
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# Copy SSH and PAM configuration from build context
COPY config/ssh/sshd_config.d-container.conf /etc/ssh/sshd_config.d/99-container.conf
COPY config/pam.d/sshd /etc/pam.d/sshd
COPY config/pam.d/password-auth /etc/pam.d/password-auth
COPY config/pam.d/system-auth /etc/pam.d/system-auth

# Create ansible user with SSH access
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible && \
    mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    touch /home/ansible/.ssh/authorized_keys && \
    chmod 600 /home/ansible/.ssh/authorized_keys && \
    chown -R ansible:ansible /home/ansible/.ssh && \
    mkdir -p /home/ansible/.ansible/tmp && \
    chown -R ansible:ansible /home/ansible/.ansible

# Enable systemd user sessions and remove nologin
RUN ln -sf /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service && \
    systemctl enable systemd-user-sessions.service || true
RUN rm -f /run/nologin

# Enable SSH service
RUN systemctl enable sshd.service

VOLUME ["/sys/fs/cgroup"]
EXPOSE 22
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]
