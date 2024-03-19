###############################################################################
# NAME: k8s Cluster Init
# AUTHOR: Infrasaurus
# VERSION: v0.1.29
# LAST MODIFIED: 15-MAR-2024
###############################################################################
# README
# Initializes a Kubernetes cluster on the current node.
# - Installs Cilium for networking
#
# Assumes user has/is root and/or sudoer privileges.
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
cilium install --version 1.15.2