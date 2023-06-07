#!/usr/bin/env bash

{
  cat > "kube-controller-manager.service" <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  cat > "kube-scheduler.yaml" <<EOF
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

  cat > "kube-scheduler.service" <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  KUBERNETES_PUBLIC_ADDRESS="192.168.56.5"
  CONTROLPLANE_IPS=("192.168.56.11" "192.168.56.12" "192.168.56.13")

  for i in ${!CONTROLPLANE_IPS[@]}; do
    node_name="controller-$(( $i + 1))"
    cat > "${node_name}-kube-apiserver.service" <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${CONTROLPLANE_IPS[$i]} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://192.168.56.11:2379,https://192.168.56.12:2379,https://192.168.56.13:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-account-issuer=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=4
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  done

  for instance in controller-1 controller-2 controller-3; do
    vagrant ssh ${instance} -c 'echo -e "192.168.56.21 node-1\n192.168.56.22 node-2"|sudo tee -a /etc/hosts'

    vagrant ssh ${instance} -c "sudo mkdir -p /var/lib/kubernetes/ && \
      sudo mkdir -p /etc/kubernetes/config"
    
    vagrant ssh ${instance} -c "sudo cp /vagrant/${node_name}-kube-apiserver.service /etc/systemd/system/kube-apiserver.service && \
      sudo cp kube-controller-manager.kubeconfig /var/lib/kubernetes/ && \
      sudo cp /vagrant/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service && \
      sudo cp kube-scheduler.kubeconfig /var/lib/kubernetes/ && \
      sudo cp /vagrant/kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml && \
      sudo cp /vagrant/kube-scheduler.service /etc/systemd/system/kube-scheduler.service"

    vagrant ssh ${instance} -c "wget -q --show-progress --https-only --timestamping \
        https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver \
        https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager \
        https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler \
        https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"

    vagrant ssh ${instance} -c "chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl && \
        sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/"

    vagrant ssh ${instance} -c "sudo cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
          service-account-key.pem service-account.pem \
          encryption-config.yaml /var/lib/kubernetes/"

    vagrant ssh ${instance} -c "sudo systemctl daemon-reload && \
        sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler && \
        sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler"
  done

  cat > "kubelet-authorizer.yaml" <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF

  vagrant ssh controller-1 -c "kubectl apply --kubeconfig /vagrant/admin.kubeconfig -f /vagrant/kubelet-authorizer.yaml"
}
