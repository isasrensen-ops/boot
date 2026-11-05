#!/usr/bin/env bash
# Romi OS: загрузка сервера одной командой из VNC.
set -euo pipefail
R=https://raw.githubusercontent.com/isasrensen-ops/boot/main
read -rp "Пароль загрузки: " P </dev/tty
S=/root/romi-secrets; mkdir -p $S; chmod 700 $S
curl -fsSL $R/s.enc | openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -pass "pass:$P" | tar -xz -C $S
chmod 600 $S/*
apt-get update -q && apt-get install -yq git curl openssl
mkdir -p /root/.ssh
ssh-keyscan -p 443 ssh.github.com >> /root/.ssh/known_hosts 2>/dev/null
export GIT_SSH_COMMAND="ssh -i $S/deploy_key -p 443"
[ -d /opt/romi-os/.git ] || git clone ssh://git@ssh.github.com:443/isasrensen-ops/romi-os.git /opt/romi-os
cd /opt/romi-os
git config core.sshCommand "ssh -i $S/deploy_key -p 443"
cp $S/env .env
bash deploy/install.sh
