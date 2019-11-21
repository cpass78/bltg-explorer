#!/bin/bash
# Download latest node and install.
bltglink=`curl -s https://api.github.com/repos/Block-Logic-Technology-Group/bltg/releases/latest | grep browser_download_url | grep x86_64-linux | cut -d '"' -f 4`
mkdir -p /tmp/bltg
cd /tmp/bltg
curl -Lo bltg.tar.gz $bltglink
tar -xzf bltg.tar.gz
sudo mv ./bin/* /usr/local/bin
cd
rm -rf /tmp/bltg
mkdir ~/.bltg

# Setup configuration for node.
rpcuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
cat >~/.bltg/bltg.conf <<EOL
rpcuser=$rpcuser
rpcpassword=$rpcpassword
server=1
daemon=1
txindex=1
EOL

# Start node.
bltgd
