{
  KUBERNETES_PUBLIC_ADDRESS="192.168.56.5"

  for instance in node-1 node-2; do
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=../files/ca.pem \
        --embed-certs=true \
        --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
        --kubeconfig=${instance}.kubeconfig

    kubectl config set-credentials system:node:${instance} \
        --client-certificate=../files/${instance}.pem \
        --client-key=../files/${instance}-key.pem \
        --embed-certs=true \
        --kubeconfig=${instance}.kubeconfig

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:node:${instance} \
        --kubeconfig=${instance}.kubeconfig

    kubectl config use-context default --kubeconfig=${instance}.kubeconfig
  done
}

mv node-1* ../files
mv node-2* ../files