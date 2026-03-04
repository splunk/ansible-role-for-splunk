FROM almalinux:9
ENV container=docker

RUN dnf -y install systemd systemd-sysv openssh-server sudo python3 passwd authselect && \
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

RUN mkdir /var/run/sshd && \
    ssh-keygen -A && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/^UsePAM no$/#UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd

RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible && \
    mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    touch /home/ansible/.ssh/authorized_keys && \
    chmod 600 /home/ansible/.ssh/authorized_keys && \
    chown -R ansible:ansible /home/ansible/.ssh && \
    mkdir -p /home/ansible/.ansible && \
    mkdir -p /home/ansible/.ansible/tmp && \
    chown -R ansible:ansible /home/ansible/.ansible

# Use distro-default PAM configuration for sudo

# Create an extremely minimal PAM configuration for SSH in container environment
# This completely replaces the default sshd PAM config to bypass preauth failures
RUN echo -e '#%PAM-1.0\n\
# Minimal PAM configuration for SSH in container environment\n\
# Auth section - make pam_unix sufficient for all auth\n\
auth       sufficient   pam_unix.so\n\
\n\
# Account section - use pam_permit.so to always allow access\n\
account    sufficient   pam_permit.so\n\
\n\
# Password section\n\
password   sufficient   pam_unix.so sha512 shadow\n\n\
# Session section - minimal required\n\
session    optional     pam_unix.so\n\
session    optional     pam_systemd.so' > /etc/pam.d/sshd

# Configure SSH server for container environment
RUN echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config && \
    echo "StrictModes no" >> /etc/ssh/sshd_config

# Fix systemd to allow unprivileged user login
# Enable systemd-user-sessions service by creating symlink manually and ensure it starts at boot
RUN ln -sf /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service && \
    systemctl enable systemd-user-sessions.service || true

# Create a simplified password-auth file that always permits account access
RUN echo -e '#%PAM-1.0\n\
# Minimal PAM configuration for container environment\n\
# Auth section - make pam_unix sufficient for all auth\n\
auth       sufficient   pam_unix.so\n\
\n\
# Account section - always permit access\n\
account    sufficient   pam_permit.so\n\
\n\
# Password section\n\
password   sufficient   pam_unix.so sha512 shadow\n\n\
# Session section - minimal required\n\
session    optional     pam_unix.so\n\
session    optional     pam_systemd.so' > /etc/pam.d/password-auth

# Create a simplified system-auth file that always permits account access
RUN echo -e '#%PAM-1.0\n\
# Minimal PAM configuration for container environment\n\
# Auth section - make pam_unix sufficient for all auth\n\
auth       sufficient   pam_unix.so\n\
\n\
# Account section - always permit access\n\
account    sufficient   pam_permit.so\n\
\n\
# Password section\n\
password   sufficient   pam_unix.so sha512 shadow\n\n\
# Session section - minimal required\n\
session    optional     pam_unix.so\n\
session    optional     pam_systemd.so' > /etc/pam.d/system-auth

# Remove /run/nologin if it exists to allow logins immediately
RUN rm -f /run/nologin

# Ensure SSH server is properly configured for key authentication
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config && \
    echo "StrictModes no" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# Ensure SSH service is enabled
RUN systemctl enable sshd.service

VOLUME ["/sys/fs/cgroup"]
EXPOSE 22
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]