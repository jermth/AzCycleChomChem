#! /bin/bash


install_duo=`jetpack config duo.install`
if [ $install_duo == 'true' ]
then
  yum install -y openssl-devel gcc pam-devel

  cd /tmp	
  wget https://dl.duosecurity.com/duo_unix-latest.tar.gz
  tar zxf duo_unix-latest.tar.gz
  cd duo_unix-1.10.1
  ./configure --with-pam --prefix=/usr && make && sudo make install

  mv /etc/pam.d/sshd /etc/pam.d/sshd.original
  cp $CYCLECLOUD_SPEC_PATH/files/pam.d.sshd /etc/pam.d/sshd
  mv /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.original
  cp $CYCLECLOUD_SPEC_PATH/files/pam.d.system-auth-ac /etc/pam.d/system-auth-ac

  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original

cat << EOF >> /etc/ssh/sshd_config 
PubkeyAuthentication yes
PasswordAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
UsePAM yes
ChallengeResponseAuthentication yes
UseDNS no
EOF

  systemctl restart sshd
fi

