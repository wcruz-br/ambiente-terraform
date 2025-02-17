#!/bin/bash

# Instala os pacotes listados em requirements.txt, usando apt install
while IFS= read -r package
do
    sudo apt install -y "$package"
done < "apt-requirements.txt"

# Instala os pacotes listados em pipx-requirements.txt
while IFS= read -r package
do
    pipx install "$package"
done < "pipx-requirements.txt"

# Instala roles do Ansible
ansible-galaxy install -r ansible-requirements.yml
