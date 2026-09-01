#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s USER PASSWORD SUDO\\n' "$0" >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 2
fi

user_name="$1"
password="$2"
sudo_user="$3"

case "${user_name}" in
    ""|*[!a-zA-Z0-9_-]*)
        printf 'Invalid username: %s\\n' "${user_name}" >&2
        exit 2
        ;;
esac

if ! getent group "${user_name}" >/dev/null 2>&1; then
    addgroup "${user_name}"
fi

if ! id "${user_name}" >/dev/null 2>&1; then
    useradd -m -s /usr/bin/zsh -g "${user_name}" "${user_name}"
fi

printf '%s:%s\\n' "${user_name}" "${password}" | chpasswd

if [ "${sudo_user}" = "yes" ]; then
    usermod -aG sudo "${user_name}"
fi

install -d -m 0755 /run/sshd
cat > /etc/ssh/sshd_config.d/99-container.conf <<'SSHD'
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin no
UsePAM yes
SSHD

ssh-keygen -A
/usr/sbin/sshd -t
exec /usr/sbin/sshd -D -e
