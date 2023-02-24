{

CONTROLPLANE_IPS="192.168.56.11,192.168.56.12,192.168.56.13"
LOADBALANCER_IP="192.168.56.5"
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=../files/ca.pem \
  -ca-key=../files/ca-key.pem \
  -config=../files/ca-config.json \
  -hostname=10.32.0.1,${CONTROLPLANE_IPS},${LOADBALANCER_IP},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}

mv kubernetes* ../files