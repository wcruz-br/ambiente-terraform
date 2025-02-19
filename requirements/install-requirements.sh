#!/bin/bash

# Instala os pacotes listados em requirements.txt, usando apt install
while IFS= read -r package
do
    sudo apt install -y "$package"
done < "apt-requirements.txt"

# Instala pacotes do Python
pip3 install -r requirements.txt

# Instala roles do Ansible
ansible-galaxy install -r ansible-requirements.yml
