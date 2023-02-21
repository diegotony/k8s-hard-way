{
  for instance in node-1 node-2; do
    vagrant ssh ${instance} -c "cp -av /vagrant/ca.pem \
      /vagrant/${instance}-key.pem \
      /vagrant/${instance}.pem \
      /home/vagrant"
  done

  for instance in controller-1 controller-2 controller-3; do
    vagrant ssh ${instance} -c "cp -av /vagrant/ca.pem \
      /vagrant/ca-key.pem \
      /vagrant/kubernetes.pem \
      /vagrant/kubernetes-key.pem \
      /vagrant/service-account.pem \
      /vagrant/service-account-key.pem \
      /home/vagrant"
  done
}
