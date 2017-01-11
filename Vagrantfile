# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ga-egeodesy"
  config.ssh.username = "guest"
  config.ssh.password = "demo"

  config.vm.network "forwarded_port", guest: 8081, host: 9081 # gws
  config.vm.network "forwarded_port", guest: 8082, host: 9082 # geoserver
  config.vm.network "forwarded_port", guest: 8083, host: 9083 # openam
  config.vm.network "forwarded_port", guest: 5433, host: 5433 # db
  config.vm.network "forwarded_port", guest: 5555, host: 5555 # site log manager app

  config.vm.provider "virtualbox" do |v|
      v.gui = true
  end

  config.vm.provision "shell",
      env: {"host_http_proxy" => ENV["http_proxy"]},
      inline: <<-SHELL
#!/usr/bin/env bash

set -e

# Inherit host's http proxy setting
if [ -n "${host_http_proxy}" ]; then
    /etc/nixos/set-proxy.sh ${host_http_proxy}
else
    /etc/nixos/unset-proxy.sh
fi

SHELL

  config.vm.provision :reload

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
#!/usr/bin/env bash

set -e

# Backup and remove existing maven settings file
function removeMavenSettings {
    if [ -f ~/.m2/settings.xml ]; then
        mv ~/.m2/settings.xml ~/.m2/settings-$(date +%Y-%m-%dT%H:%M:%S)
    fi
}

# Configure maven to use the system proxy setting
if [ -n "${http_proxy}" ]; then
    export https_proxy=${http_proxy}

    proxy_host=$(echo ${http_proxy} | sed 's/http[s]*:\\/\\///' | sed 's/:.*//')
    proxy_port=$(echo ${http_proxy} | sed 's/http[s]*:\\/\\///' | sed 's/.*://') 

    mkdir -p ~/.m2
    removeMavenSettings
      
    cat > ~/.m2/settings.xml <<< '
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <proxies>
    <proxy>
      <id>https</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>'"${proxy_host}"'</host>
      <port>'"${proxy_port}"'</port>
      <nonProxyHosts>localhost</nonProxyHosts>
    </proxy>
    <proxy>
      <id>http</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>'"${proxy_host}"'</host>
      <port>'"${proxy_port}"'</port>
      <nonProxyHosts>localhost</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
'
else
    removeMavenSettings
fi

SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
#!/usr/bin/env bash

set -e

# Clone, compile, and test all eGeodesy projects
if [ ! -d ~/dev ]; then
    cd ~
    mkdir dev
    cd dev
    git clone https://github.com/GeoscienceAustralia/egeodesy
    cd egeodesy
    ./clone.sh
    nix-shell --command "mvn install -DskipTests"
    cd ../geodesy-web-services
    nix-shell --command "docker-compose up -d"
    nix-shell --command "mvn verify -pl gws-system-test"
    cd ../gnss-site-manager
    CHROME_BIN=chromium nix-shell --command "npm install && xvfb-run npm test"
fi

SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
#!/usr/bin/env nix-shell
#!nix-shell /home/guest/dev/egeodesy/shell.nix -i bash

# Start all services

cd ~/dev/geodesy-web-services
docker-compose up -d

cd ~/dev/gnss-site-manager
# daemonise `npm run serve.docker`
nohup npm run serve.docker 0<&- &>/dev/null &

SHELL

end
