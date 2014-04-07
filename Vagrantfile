VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|

  # os image
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # server
  config.vm.define "logstash" do |logstash|

        # hostname
        logstash.vm.hostname = "logstash.cc.de"
        # public network
	logstash.vm.network "public_network", :bridge => "wlan0"
        # private network
	# logstash.vm.network "private_network", ip: "10.0.1.111"
        logstash.vm.provider "logstash" do |logstash|
                logstash.customize ["modifyvm", :id, "--memory", "1024"]
        end

        # Set the Timezone
        config.vm.provision :shell, :inline => "echo \"Europe/Berlin\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

        # upgrade puppet
        logstash.vm.provision :shell, :path => "upgrade-puppet.sh"

        # provisioning with puppet
        logstash.vm.provision "puppet" do |puppet|
                puppet.manifests_path = "manifests"
                puppet.manifest_file = "init.pp"
                puppet.module_path = "modules"
#		puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
        end
  end
end
