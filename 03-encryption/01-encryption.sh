{
    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
    cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
    mv encryption-config.yaml ../files

    for instance in controller-1 controller-2 controller-3; do
        vagrant scp /mnt/c/Users/tucot/projects/k8s-hard-way/files/encryption-config.yaml ${instance}:/home/vagrant
    done


}