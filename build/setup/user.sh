#!/bin/bash
set -e

group_name="docker"

if getent group "${GID}" >/dev/null; then
    group_name="$(getent group "${GID}" | cut -d: -f1)"
elif ! getent group "${group_name}" >/dev/null; then
    groupadd -g "${GID}" "${group_name}"
fi

existing_uid_user="$(getent passwd "${UID}" | cut -d: -f1 || true)"
if [ -n "${existing_uid_user}" ] && [ "${existing_uid_user}" != "docker" ]; then
    usermod -l docker "${existing_uid_user}"
    usermod -d /home/docker -m -s /bin/bash -g "${group_name}" docker
    usermod -aG sudo docker
    echo "docker:docker" | chpasswd
elif ! id -u docker >/dev/null 2>&1; then
    useradd -m -d /home/docker -s /bin/bash -g "${group_name}" -G sudo -u "${UID}" docker -p "$(openssl passwd -1 docker)"
fi

mkdir -p /home/docker
touch /home/docker/.sudo_as_admin_successful
chown docker:"${group_name}" /home/docker/.sudo_as_admin_successful
