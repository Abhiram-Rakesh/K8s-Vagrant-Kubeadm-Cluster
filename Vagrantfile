require 'yaml'

settings = YAML.load_file(File.join(File.dirname(__FILE__), 'config/settings.yaml'))

K8S_VERSION    = settings['kubernetes_version']
CALICO_VERSION = settings['calico_version']
POD_CIDR       = settings['pod_cidr']
MASTER_IP      = settings['master_ip']

Vagrant.configure("2") do |config|

  # Global box configuration
  config.vm.boot_timeout = 600
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false

  # Common VM settings
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Control Plane Node
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: MASTER_IP

    master.vm.provider "virtualbox" do |vb|
      vb.name = "k8s-master"
      vb.memory = 4096
      vb.cpus = 2
    end

    master.vm.provision "shell", path: "scripts/common.sh"
    master.vm.provision "shell", path: "scripts/containerd.sh"
    master.vm.provision "shell", path: "scripts/kubernetes.sh",
      env: { "K8S_VERSION" => K8S_VERSION }
    master.vm.provision "shell", path: "scripts/master.sh",
      env: { "MASTER_IP" => MASTER_IP, "POD_CIDR" => POD_CIDR, "CALICO_VERSION" => CALICO_VERSION }
  end

  # Worker Node 1
  config.vm.define "k8s-worker-1" do |worker|
    worker.vm.hostname = "k8s-worker-1"
    worker.vm.network "private_network", ip: "192.168.56.11"

    worker.vm.provider "virtualbox" do |vb|
      vb.name = "k8s-worker-1"
      vb.memory = 2048
      vb.cpus = 2
    end

    worker.vm.provision "shell", path: "scripts/common.sh"
    worker.vm.provision "shell", path: "scripts/containerd.sh"
    worker.vm.provision "shell", path: "scripts/kubernetes.sh",
      env: { "K8S_VERSION" => K8S_VERSION }
    worker.vm.provision "shell", path: "scripts/worker.sh"
  end

  # Worker Node 2
  config.vm.define "k8s-worker-2" do |worker|
    worker.vm.hostname = "k8s-worker-2"
    worker.vm.network "private_network", ip: "192.168.56.12"

    worker.vm.provider "virtualbox" do |vb|
      vb.name = "k8s-worker-2"
      vb.memory = 2048
      vb.cpus = 2
    end

    worker.vm.provision "shell", path: "scripts/common.sh"
    worker.vm.provision "shell", path: "scripts/containerd.sh"
    worker.vm.provision "shell", path: "scripts/kubernetes.sh",
      env: { "K8S_VERSION" => K8S_VERSION }
    worker.vm.provision "shell", path: "scripts/worker.sh"
  end

end
