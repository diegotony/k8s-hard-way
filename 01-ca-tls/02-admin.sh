{

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
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
  admin-csr.json | cfssljson -bare admin

}

mv admin* ../files
