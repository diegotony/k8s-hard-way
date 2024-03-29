#!/usr/bin/env bash
node_ips=("192.168.56.21" "192.168.56.22")
for i in ${!node_ips[@]}; do
  node_name="node-$(( $i + 1))"
  cat > ${node_name}-csr.json <<EOF

{
  "CN": "system:node:${node_name}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
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
  -hostname=${node_name},${external_ip}  \
  -profile=kubernetes \
  ${node_name}-csr.json | cfssljson -bare ${node_name}
done

mv node-1* ../files
mv node-2* ../files
