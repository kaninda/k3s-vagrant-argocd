Vagrant.configure("2") do |config|
  config.vm.define "gitops-lab" do |node|
    node.vm.box = "ubuntu/jammy64"
    node.vm.hostname = "gitops-lab"

    node.vm.network "private_network", ip: "192.168.56.10"

    node.vm.provider "virtualbox" do |vb|
      vb.name = "gitops-lab"
      vb.memory = 4096
      vb.cpus = 2
    end

    node.vm.provision "shell", inline: <<-SHELL
      hostnamectl set-hostname gitops-lab
      curl -sfL https://get.k3s.io | sh -
      chmod 644 /etc/rancher/k3s/k3s.yaml
    SHELL
  end
end

