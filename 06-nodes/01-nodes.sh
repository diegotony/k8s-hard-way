#!/usr/bin/env bash

{

  cat > 99-loopback.conf <<EOF
{
  "cniVersion": "0.4.0",
  "name": "lo",
  "type": "loopback"
}
EOF

  cat > containerd-config.toml <<EOF
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

  cat > containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

  cat > kube-proxy-config.yaml <<EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

  cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  node_ips=("192.168.56.21", "192.168.56.22")

  for i in ${!node_ips[@]}; do
    node_name="node-$(( $i + 1))"
    vagrant ssh ${node_name} -c "sudo apt update && \
      sudo apt install -y socat conntrack ipset"

    vagrant ssh ${node_name} -c "wget -q --show-progress --https-only --timestamping \
      https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz \
      https://github.com/opencontainers/runc/releases/download/v1.0.0-rc93/runc.amd64 \
      https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz \
      https://github.com/containerd/containerd/releases/download/v1.4.4/containerd-1.4.4-linux-amd64.tar.gz \
      https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy \
      https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet"

    vagrant ssh ${node_name} -c "sudo mkdir -p \
      /etc/cni/net.d \
      /opt/cni/bin \
      /var/lib/kubelet \
      /var/lib/kube-proxy \
      /var/lib/kubernetes \
      /var/run/kubernetes"

    vagrant ssh ${node_name} -c "mkdir containerd && \
      tar -xvf crictl-v1.21.0-linux-amd64.tar.gz && \
      tar -xvf containerd-1.4.4-linux-amd64.tar.gz -C containerd && \
      sudo tar -xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/ && \
      sudo mv runc.amd64 runc && \
      chmod +x crictl kubectl kube-proxy kubelet runc && \
      sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/ && \
      sudo mv containerd/bin/* /bin/"

    cat > ${node_name}-cni-bridge.conf <<EOF
{
  "cniVersion": "0.4.0",
  "name": "bridge",
  "type": "bridge",
  "bridge": "cnio0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "ranges": [
      [{"subnet": "10.200.$(( $i + 1)).0/24"}]
    ],
    "routes": [{"dst": "0.0.0.0/0"}]
  }
}
EOF

    vagrant ssh ${node_name} -c "sudo cp /vagrant/${node_name}-cni-bridge.conf /etc/cni/net.d/10-bridge.conf && \
      sudo cp /vagrant/99-loopback.conf /etc/cni/net.d/99-loopback.conf"

    vagrant ssh ${node_name} -c "sudo mkdir -p /etc/containerd/ && \
      sudo cp /vagrant/containerd-config.toml /etc/containerd/config.toml && \
      sudo cp /vagrant/containerd.service /etc/systemd/system/containerd.service"


    # Configure kubelet

    vagrant ssh ${node_name} -c "sudo cp /vagrant/${node_name}-key.pem /vagrant/${node_name}.pem /var/lib/kubelet/ && \
      sudo cp /vagrant/${node_name}.kubeconfig /var/lib/kubelet/kubeconfig && \
      sudo cp /vagrant/ca.pem /var/lib/kubernetes/"

    cat > ${node_name}-kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --node-ip="${node_ips[$i]}" \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    cat > ${node_name}-kubelet-config.yaml <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.$(( $i + 1)).0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${node_name}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${node_name}-key.pem"
EOF

    vagrant ssh ${node_name} -c "sudo cp /vagrant/${node_name}-kubelet-config.yaml /var/lib/kubelet/kubelet-config.yaml && \
      sudo cp /vagrant/${node_name}-kubelet.service /etc/systemd/system/kubelet.service"

    # Configure kube-proxy
    vagrant ssh ${node_name} -c "sudo cp /vagrant/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig && \
      sudo cp /vagrant/kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml && \
      sudo cp /vagrant/kube-proxy.service /etc/systemd/system/kube-proxy.service"

    # Run
    vagrant ssh ${node_name} -c "sudo systemctl daemon-reload && \
      sudo systemctl enable containerd kubelet kube-proxy && \
      sudo systemctl start containerd kubelet kube-proxy"

  done
}
