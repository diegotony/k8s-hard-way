# default recipe to display help information
default:
    @just --list

# Create the resources
create:
    vagrant up

# Install Dependencies (LINUX)
# dependencies:
#     sudo apt install curl wget -y
#     wget -q --show-progress --https-only --timestamping https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
#     chmod +x cfssl cfssljson
#     sudo mv cfssl cfssljson /usr/local/bin/
#     cfssl version
# Destroy everything
destroy:
    vagrant destroy -f -g

# Provisioning a CA and Generating TLS Certificates
ca_tls:
    cd 01-ca-tls && sh 01-ca.sh
    cd 01-ca-tls && sh 02-admin.sh

 
