#! /bin/sh

# Check for existence of passphrase
if [ ! -f ~/.ssh/id_rsa.pub ]; then
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
fi
