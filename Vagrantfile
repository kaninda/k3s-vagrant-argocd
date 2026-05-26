Vagrant.configure("2") do |config|

  # ── Control Plane ───────────────────────────────────────────────
  config.vm.define "k3s-cp" do |node|
    node.vm.box = "ubuntu/jammy64"
    node.vm.hostname = "k3s-cp"
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.network "forwarded_port", guest: 9090, host: 9090

    node.vm.provider "virtualbox" do |vb|
      vb.name = "k3s-cp"
      vb.memory = 2048
      vb.cpus = 2
    end

    node.vm.provision "shell", inline: <<-SHELL
      set -e

      hostnamectl set-hostname k3s-cp

      until ip addr show | grep -q "192.168.56.10"; do
        echo "Waiting for private network interface..."
        sleep 2
      done

      curl -sfL https://get.k3s.io | sh -s - server \
        --node-ip=192.168.56.10 \
        --advertise-address=192.168.56.10 \
        --tls-san=192.168.56.10 \
        --write-kubeconfig-mode=644

      until systemctl is-active --quiet k3s; do
        echo "Waiting for k3s server..."
        sleep 2
      done

      until [ -f /var/lib/rancher/k3s/server/node-token ]; do
        echo "Waiting for node token..."
        sleep 1
      done

      cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
      chmod 644 /vagrant/node-token

       # ── Helm ──────────────────────────────────────────────────────────
       echo "Installing Helm..."
       curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

       # Kubeconfig standard pour l'user vagrant
       mkdir -p /home/vagrant/.kube
       cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
       chown vagrant:vagrant /home/vagrant/.kube/config

       echo "Control plane ready. Token exported to /vagrant/node-token"
    SHELL
  end

  # ── Worker Node ─────────────────────────────────────────────────
  config.vm.define "k3s-worker" do |node|
    node.vm.box = "ubuntu/jammy64"
    node.vm.hostname = "k3s-worker"
    node.vm.network "private_network", ip: "192.168.56.11"

    node.vm.provider "virtualbox" do |vb|
      vb.name = "k3s-worker"
      vb.memory = 2048
      vb.cpus = 2
    end

    node.vm.provision "shell", inline: <<-SHELL
      set -e

      hostnamectl set-hostname k3s-worker

      until ip addr show | grep -q "192.168.56.11"; do
        echo "Waiting for private network interface..."
        sleep 2
      done

      until [ -f /vagrant/node-token ]; do
        echo "Waiting for control plane token..."
        sleep 3
      done

      TOKEN=$(cat /vagrant/node-token)

      curl -sfL https://get.k3s.io | sh -s - agent \
        --server=https://192.168.56.10:6443 \
        --token="$TOKEN" \
        --node-ip=192.168.56.11

      echo "Worker node joined the cluster"
    SHELL
  end
end