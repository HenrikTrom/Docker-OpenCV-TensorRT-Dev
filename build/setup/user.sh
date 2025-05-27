# Create non-root user with sudo permissions
groupadd -g $GID docker
useradd -rm -d /home/docker -s /bin/bash -g docker -G sudo -u $UID docker -p "$(openssl passwd -1 docker)"
# Avoid sudo warning on first use
touch /home/docker/.sudo_as_admin_successful