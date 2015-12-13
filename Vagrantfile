# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define :php7 do |php7|
        php7.vm.box = "Debian8"
        php7.vm.box_url = "echo deb http://dl.hhvm.com/debian jessie main | sudo tee /etc/apt/sources.list.d/hhvm.list"
        php7.vm.provider "virtualbox" do |v|
            # show a display for easy debugging
            v.gui = false

            # RAM size
            v.memory = 1024

            # Allow symlinks on the shared folder
            v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        end

        # allow external connections to the machine
        #php7.vm.network "forwarded_port", guest: 80, host: 8080

        # Shared folder over NFS
        php7.vm.synced_folder ".", "/vagrant", type: "nfs"

        php7.vm.network "private_network", ip: "192.168.33.30"

        # Shell provisioning
        php7.vm.provision :shell, :path => "run.sh"
    end

end
