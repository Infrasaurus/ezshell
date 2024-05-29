###############################################################################
# NAME: k8s Cluster Init
# AUTHOR: Infrasaurus
# VERSION: v0.1.29
# LAST MODIFIED: 15-MAR-2024
###############################################################################
# README
# Initializes a Kubernetes cluster on the current node.
# - Installs Cilium for networking
# - Installs NFS CSI Driver for storage
#
# Assumes user has/is root and/or sudoer privileges. Run only on primary
# control plane.
###############################################################################
#!/bin/bash
exec &>> output.log
# Installs Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# Installs Cilium
cilium install --version 1.15.4
# Installs NFS CSI Driver; DOUBLE-CHECK SCRIPT BEFORE INSTALL
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.6.0/deploy/install-driver.sh | bash -s v4.6.0 --
# Configures NFS storage class
cat <<EOF | tee nfs_class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: NFS.SERVER.EXAMPLE
  share: /
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4.1
EOF
kubectl apply -f nfs_class.yaml