export DEBIAN_FRONTEND=noninteractive

echo "[TASK 1] show whoami"
whoami
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Letting iptables see bridged traffic"
modprobe br_netfilter

echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/k8s.conf<<EOF
br_netfilter
EOF

echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "[TASK 6] Install docker"
apt-get update
apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
     "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y

echo "[TASK 6] Configure the Docker daemon, in particular to use systemd for the management of the container’s cgroups."
mkdir /etc/Docker
cat >>/etc/docker/daemon.json<<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
    "max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF
systemctl enable docker
systemctl daemon-reload
systemctl restart docker
systemctl status docker.service

echo "[TASK 7] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl -y

echo "[TASK 8] Add apt repo for kubernetes"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=1.28.0-00 kubeadm=1.28.0-00 kubectl=1.28.0-00 -y
