
{
  for instance in node-1 node-2; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/ca.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/${instance}-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/${instance}.pem ${instance}:/home/vagrant

  done

  for instance in controller-1 controller-2 controller-3; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/ca-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/kubernetes.pem  ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/kubernetes-key.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/service-account.pem ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/service-account-key.pem ${instance}:/home/vagrant
  done
}
