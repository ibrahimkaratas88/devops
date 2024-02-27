#! /bin/bash
echo version 1
apt-get update -y
hostnamectl set-hostname "$(hostname).${TF_VAR_REGION}.compute.internal"
free -m
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
cat << EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


wget https://github.com/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz
apt-get install libseccomp2
tar --no-overwrite-dir -C / -xzf cri-containerd-cni-1.4.3-linux-amd64.tar.gz
systemctl daemon-reload
systemctl start containerd
mkdir -p /etc/systemd/system/kubelet.service.d

cat << EOF > /etc/systemd/system/kubelet.service.d/0-containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
systemctl daemon-reload

apt-get install apt-transport-https curl ca-certificates awscli jq -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
apt-get update -q && \
apt-get install -qy kubelet=1.22.2-00 kubectl=1.22.2-00 kubeadm=1.22.2-00 

export az=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
export instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id )
echo -e "$(aws secretsmanager get-secret-value --secret-id gitlabkey${TF_VAR_PROJECT_IDENTIFIER} --region ${TF_VAR_REGION} | jq .SecretString | tr -d '"')" > gitlab-ec2-access.cer
mv gitlab-ec2-access.cer /home/ubuntu/
chmod 400 /home/ubuntu/gitlab-ec2-access.cer
export PUBLIC_IP=$(aws secretsmanager get-secret-value --secret-id publicip${TF_VAR_PROJECT_IDENTIFIER} --region ${TF_VAR_REGION} | jq .SecretString | tr -d '"')
cd /home/ubuntu

export JOIN_COMMAND=$(ssh -i gitlab-ec2-access.cer -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP sudo kubeadm token create --ttl 30m --print-join-command)

$JOIN_COMMAND --v=5 --ignore-preflight-errors=All 

export HOSTNAME=$(hostname)

cat << EOF > patch.json
{
  "spec": {
    "providerID":"aws:///$az/$instance_id"
  }
}
EOF

cat << EOF > command.sh
kubectl patch node $HOSTNAME -p "\$(cat $HOSTNAME.json)"
EOF

scp -i gitlab-ec2-access.cer patch.json ubuntu@$PUBLIC_IP:/home/ubuntu/$HOSTNAME.json
scp -i gitlab-ec2-access.cer command.sh ubuntu@$PUBLIC_IP:/home/ubuntu/$HOSTNAME.sh

ssh -i gitlab-ec2-access.cer -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP bash $HOSTNAME.sh
