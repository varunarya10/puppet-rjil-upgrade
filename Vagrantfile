# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

Vagrant.configure("2") do |config|

  default_flavor = 'small'
  default_image = 'trusty'

  # allow users to set their own environment
  # which effect the hiera hierarchy and the
  # cloud file that is used
  environment = ENV['env'] || 'vagrant-vbox'
  layout = ENV['layout'] || 'full'
  map = ENV['map'] || environment

  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "lxc" do |v, override|
    override.vm.box = "fgrehm/trusty64-lxc"
  end

  last_octet = 41
  env_data = YAML.load_file("environment/#{layout}.yaml")

  map_data = YAML.load_file("environment/#{map}.map.yaml")

  machines = {}
  env_data['resources'].each do |name, info|
    (1..info['number']).to_a.each do |idx|
      machines["#{name}#{idx}"] = info
    end
  end

  machines.each do |node_name, info|

    config.vm.define(node_name) do |config|

      config.vm.provider :virtualbox do |vb, override|
        image = info['image'] || default_image
        override.vm.box = map_data['image']['virtualbox'][image]

        flavor = info['flavor'] || default_flavor
        vb.memory = map_data['flavor'][flavor]['ram']
        vb.cpus = map_data['flavor'][flavor]['cpu']
      end

      config.vm.synced_folder("hiera/", '/etc/puppet/hiera/')
      config.vm.synced_folder("modules/", '/etc/puppet/modules/')
      config.vm.synced_folder("manifests/", '/etc/puppet/modules/rjil/manifests/')
      config.vm.synced_folder("files/", '/etc/puppet/modules/rjil/files/')
      config.vm.synced_folder("templates/", '/etc/puppet/modules/rjil/templates/')
      config.vm.synced_folder("lib/", '/etc/puppet/modules/rjil/lib/')
      config.vm.synced_folder(".", "/etc/puppet/manifests")

      # This seems wrong - Soren
      config.vm.provision 'shell', :inline =>
      'cp /etc/puppet/hiera/hiera.yaml /etc/puppet'

      config.vm.host_name = "#{node_name}.domain.name"
      ['consul'].each do |x|
        config.vm.provision 'shell', :inline =>
        "[ -e '/etc/facter/facts.d/#{x}.txt' -o -n '#{ENV["#{x}_discovery_token"]}' ] || (echo 'No #{x} discovery token set. Bailing out. Use \". newtokens.sh\" to get tokens.' ; exit 1)"
        config.vm.provision 'shell', :inline =>
        "mkdir -p /etc/facter/facts.d; [ -e '/etc/facter/facts.d/#{x}.txt' ] && exit 0; echo #{x}_discovery_token=#{ENV["#{x}_discovery_token"]} > /etc/facter/facts.d/#{x}.txt"
      end

      config.vm.provision 'shell', :inline =>
      "echo env=#{environment} > /etc/facter/facts.d/env.txt"

      if ENV['http_proxy']
        config.vm.provision 'shell', :inline =>
        "echo \"Acquire::http { Proxy \\\"#{ENV['http_proxy']}\\\" }\" > /etc/apt/apt.conf.d/03proxy"
      end

      # run apt-get update and install pip
      unless ENV['NO_APT_GET_UPDATE'] == 'true'
        config.vm.provision 'shell', :inline =>
        'apt-get update; apt-get install -y git curl;'
      end

      # upgrade puppet
      if ENV['http_proxy']
        config.vm.provision 'shell', :inline =>
        "test -e puppet.deb && exit 0; release=$(lsb_release -cs);http_proxy=#{ENV['http_proxy']} wget -O puppet.deb http://apt.puppetlabs.com/puppetlabs-release-${release}.deb;dpkg -i puppet.deb;apt-get update;apt-get install -y puppet-common=3.6.2-1puppetlabs1"
      else
        config.vm.provision 'shell', :inline =>
        "test -e puppet.deb && exit 0; release=$(lsb_release -cs);wget -O puppet.deb http://apt.puppetlabs.com/puppetlabs-release-${release}.deb;dpkg -i puppet.deb;apt-get update;apt-get install -y puppet-common=3.6.2-1puppetlabs1"
      end
      config.vm.provision 'shell', :inline =>
      'puppet apply --detailed-exitcodes --debug -e "include rjil::jiocloud"; if [[ $? = 1 || $? = 4 || $? = 6 ]]; then apt-get update; puppet apply --detailed-exitcodes --debug -e "include rjil::jiocloud"; fi'

      net_prefix = ENV['NET_PREFIX'] || "192.168.100.0"
      config.vm.network "private_network", :type => :dhcp, :ip => net_prefix, :netmask => "255.255.255.0"
    end
  end
end
