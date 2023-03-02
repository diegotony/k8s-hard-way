#!/usr/bin/env bash

{
  CONTROLPLANE_IPS=("192.168.56.11" "192.168.56.12" "192.168.56.13")

  for i in ${!CONTROLPLANE_IPS[@]}; do
    node_name="controller-$(( $i + 1))"
    cat > "${node_name}-etcd.service" <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${node_name} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${CONTROLPLANE_IPS[$i]}:2380 \\
  --listen-peer-urls https://${CONTROLPLANE_IPS[$i]}:2380 \\
  --listen-client-urls https://${CONTROLPLANE_IPS[$i]}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${CONTROLPLANE_IPS[$i]}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-1=https://192.168.56.11:2380,controller-2=https://192.168.56.12:2380,controller-3=https://192.168.56.13:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  done
    mv *-etcd.service ../files

  for instance in controller-1 controller-2 controller-3; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/${instance}-etcd.service ${instance}:/home/vagrant

    vagrant ssh ${instance} -c "sudo cp /vagrant/${instance}-etcd.service \
      /etc/systemd/system/etcd.service"

    vagrant ssh ${instance} -c "wget -q --show-progress --https-only --timestamping \
      https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"

    vagrant ssh ${instance} -c "tar -xvf etcd-v3.4.15-linux-amd64.tar.gz && \
        sudo mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/"

    vagrant ssh ${instance} -c "sudo mkdir -p /etc/etcd /var/lib/etcd && \
        sudo chmod 700 /var/lib/etcd && \
        sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/"

    vagrant ssh ${instance} -c "sudo systemctl daemon-reload && \
        sudo systemctl enable etcd && \
        sudo systemctl start etcd"
  done
}
