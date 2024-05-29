###############################################################################
# NAME: k8s Install Script
# AUTHOR: Infrasaurus
# VERSION: v0.1.29
# LAST MODIFIED: 12-FEB-2024
###############################################################################
# README
# Installs Kubernetes from its binaries onto a Debian-based distribution.
# - Installs containerd as CRI
# - DISABLES SWAP BY DEFAULT
#   - Swap is supported since v1.28 for cgroup v2 only
#   - If your intended kubelet config will use swap, comment out line 70
# - Only installs kubectl and kubelet
#   - Use the -kubeadm flag to install that package
# - Overwrites the kubernetes.list file by default
#   - Using tee -a will append a new key to the list
#   - Each k8s minor version has own key and repository; modify as necessary
#
# Assumes user has/is root and/or sudoer privileges.
#
# Does not deploy a cluster, only installs the underlying binaries.
#
# See "K8s_Cluster.sh" for basic cluster setup with best practices.
###############################################################################
#!/bin/bash
exec &>> output.log
# Options definitions
while getopts 'lha:' OPTION; do
	case "$OPTION" in
		kubeadm)
			readonly KUBEADM=yes
				;;
			?)
				echo "Script must be run as root. Usage is k8s_install.sh [-kubeadm]" >&2
				;;
			esac
done
# Updates all packages before proceeding
echo "Updating all packages..." >&2
apt-get update && apt-get upgrade -y
# Tests for port 6443 access; needed for k8s deployment to succeed
echo "Checking availability of port 6443..." >&2
PORT=$(nc 127.0.0.1 6443)
if [ -n "$PORT" ]; then
	echo "Port 6443 is unavailable. Stopping install script."
	exit
fi
# Enables modprobe modules "overlay" and "br_netfilter", required for k8s
echo "Enabling modules..." >&2
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
# Configures iptables to function with k8s
echo "Configuring iptables..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
# Installs containerd as the container runtime
echo "Installing containerd..." >&2
apt-get install containerd -y
# Configures containerd and restarts the service
if [ ! -d "/etc/containerd" ]; then
	mkdir -p -m 755 /etc/containerd
fi
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
# Disables swap; comment out if your k8s cluster will enable swap (BETA v1.28)
echo "Disabling swap..." >&2
swapoff -a
# Installs additional prerequisite packages
# apt-transport-https may be a dummy package; comment out if necessary
echo "Installing additional prerequisites..." >&2
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gpg
# Checks for /etc/apt/keyrings and, if does not exist, creates
echo "Installing public signing keys..." >&2
if [ ! -d "/etc/apt/keyrings" ]; then
	    mkdir -p -m 755 /etc/apt/keyrings
fi
# Adds k8s package signing key
# NOTE: Each minor version has own key! Update accordingly!
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee --append /etc/apt/sources.list.d/kubernetes.list
# Installs kubelet, kubeadm, and kubectl
echo "Installing kubelet, kubeadm and kubectl..."
apt-get update && apt-get install -y kubelet kubectl kubeadm
# Marks the current kubelet, kubeadm, and kubectl packages to be held
echo "Holding kubelet, kubeadm and kubectl packages..."
apt-mark hold kubelet kubectl kubeadm
# Creates the configuration files, if they do not exist
if [ ! -d "$HOME/.kube" ]; then
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube
fi