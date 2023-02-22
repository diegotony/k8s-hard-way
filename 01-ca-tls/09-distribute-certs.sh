
{
  for instance in node-1 node-2; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/ca.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/${instance}-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/${instance}.pem ${instance}:/home/vagrant

  done

  for instance in controller-1 controller-2 controller-3; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/ca-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/kubernetes.pem  ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/kubernetes-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/service-account.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/01-ca-tls/service-account-key.pem ${instance}:/home/vagrant
  done
}
