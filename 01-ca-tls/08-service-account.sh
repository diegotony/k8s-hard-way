{

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
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
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

}

mv service-account* ../files