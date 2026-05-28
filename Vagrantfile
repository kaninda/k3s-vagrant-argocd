Vagrant.configure("2") do |config|

  # ── Control Plane ───────────────────────────────────────────────
  config.vm.define "k3s-cp" do |node|
    node.vm.box = "ubuntu/jammy64"
    node.vm.hostname = "k3s-cp"
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.network "forwarded_port", guest: 9090, host: 9090
    node.vm.boot_timeout = 600

    node.vm.provider "virtualbox" do |vb|
      vb.name = "k3s-cp"
      vb.memory = 6144
      vb.cpus = 4
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

       # ── Helm ──────────────────────────────────────────────────────────
       echo "Installing Helm..."
       curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

       # Kubeconfig standard pour l'user vagrant
       mkdir -p /home/vagrant/.kube
       cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
       chown vagrant:vagrant /home/vagrant/.kube/config

       echo "Single-node k3s cluster ready."
    SHELL
  end
end