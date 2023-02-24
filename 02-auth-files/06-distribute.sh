{
  for instance in node-1 node-2; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/${instance}.kubeconfig ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/kube-proxy.kubeconfig ${instance}:/home/vagrant
  done

  for instance in controller-1 controller-2 controller-3; do
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/admin.kubeconfig ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/kube-controller-manager.kubeconfig ${instance}:/home/vagrant
    vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/kube-scheduler.kubeconfig ${instance}:/home/vagrant
  done
}
