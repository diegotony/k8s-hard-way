# default recipe to display help information
default:
    @just --list

# Destroy everything
clean:
    vagrant destroy -f -g
    # rm -rf files/*

# 0 Install Dependencies (LINUX)
# dependencies:
#     sudo apt install curl wget -y
#     wget -q --show-progress --https-only --timestamping https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
#     chmod +x cfssl cfssljson
#     sudo mv cfssl cfssljson /usr/local/bin/
#     cfssl version

# 1 Create the resources
create:
    vagrant up
    #  --destroy-on-error --no-provision --provider virtualbox

# 2 Provisioning CA and Generating TLS Certificates
generate_certs:
    cd 01-ca-tls && ./01-ca.sh
    cd 01-ca-tls && ./02-admin.sh
    cd 01-ca-tls && ./03-system-nodes.sh
    cd 01-ca-tls && ./04-kube-controller-manager.sh
    cd 01-ca-tls && ./05-kube-proxy.sh
    cd 01-ca-tls && ./06-kube-scheduler.sh
    cd 01-ca-tls && ./07-k8s-api-server.sh
    cd 01-ca-tls && ./08-service-account.sh

# 3 Distribute CA and TLS Certificates in nodes and controllers
distribute_certs:
    cd 01-ca-tls && ./09-distribute.sh

# 4 Provisioning auth
generate_auths:
    cd 02-auth-files && ./01-controller-manager.sh
    cd 02-auth-files && ./02-kubelet.sh
    cd 02-auth-files && ./03-kube-proxy.sh
    cd 02-auth-files && ./04-scheduler.sh
    cd 02-auth-files && ./05-admin.sh

# 5 Distribute auth
distribute_auths:
    cd 02-auth-files && ./06-distribute.sh

# 6 encryption
generate_encryption:
    cd 03-encryption && ./01-encryption.sh

# 7 generate_etcd
generate_etcd:
    cd 04-etcd && ./01-etcd.sh

# 8 generate_controlpane
generate_controlpane:
    cd 05-controlpane && ./01-controlpane.sh

# run all
run:
    @just create
    @just generate_certs
    @just distribute_certs
    @just generate_auths
    @just distribute_auths
    @just generate_encryption
    # @just generate_etcd
    # @just generate_controlpane