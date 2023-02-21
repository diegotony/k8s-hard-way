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
    # cd 01-ca-tls && sh 01-ca.sh
    # cd 01-ca-tls && sh 02-admin.sh
    # cd 01-ca-tls && sh 03-system-nodes.sh
    # cd 01-ca-tls && sh 04-kube-controller-manager.sh
    # cd 01-ca-tls && sh 05-kube-proxy.sh
    # cd 01-ca-tls && sh 06-kube-scheduler.sh
    # cd 01-ca-tls && sh 07-k8s-api-server.sh
    cd 01-ca-tls && sh 08-service-account.sh

 
