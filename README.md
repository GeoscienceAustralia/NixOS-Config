# nixos-config

## About

NixOS configuration files for VirtualBox and BYO development machines. See https://nixos.org.

The machine defined in `machines/ga/configuration.nix` is continuously built
into an OVF (Open Virtualization Format) appliance and uploaded into
http://s3-ap-southeast-2.amazonaws.com/geodesy-nixos/.

## Getting Started

### Download and import the latest OVF appliance
```
$ wget http://s3-ap-southeast-2.amazonaws.com/geodesy-nixos/nixos-16.09.XXX-x86_64-linux.ova
$ VBoxManager import nixos-16.09.XXX-x86_64-linux.ova
```
### Start the VM
```
$ VBoxManager list vms                  # print the name and UUID of the imported VM
$ VirtualBox --startvm <vmname|uuid>
```
### Login and customise the VM
```
$ ssh -p 4022 guest@localhost           # password is "change-me"
$ cd /etc/nixos
$ git clone https://github.com/GeoscienceAustralia/nixos-config .
$ ln -s machines/ga/configuration.nix
$ git checkout -b <your-branch>
$ vim configuration.nix                 # set your username, customise the configuration
$ sudo nixos-rebuild switch             # build the new configuration and switch to it
$ sudo su - <username>                  # login as your new user
$ passwd                                # change your password

$ ssh-keygen                            # generate your private and public SSH keys
                                        # upload your public SSH key to GitHub

# switch to SSH
$ cd /etc/nixos
$ git remote remove origin
$ git remote add origin git@github.com:GeoscienceAustralia/nixos-config

# commit and push to GitHub
$ git add machines/ga/configuration.nix
$ git commit -m"Customise"
$ git push -u origin <your-branch>      # push your branch to GitHub
```

### Study other developers' configurations
At GA: https://github.com/GeoscienceAustralia/nixos-config/network

Globally: http://www.google.com/search?q=github+configuration.nix

### Read about Nix and NixOS

* [Nix PhD thesis](http://grosskurth.ca/bib/2006/dolstra-thesis.pdf)
* [Nix Manual](https://nixos.org/nix/)
* [NixOS Manual](https://nixos.org/nixos/manual/)

### Keep Up-to-date

Periodically, you can rebase your branch onto the latest changes from master.

```
$ git fetch origin master:master        # Pull in the latest changes from master
$ git rebase master                     # rebase your branch
$ sudo nixos-rebuild switch             # Switch to the new configuration
$ git push -f                           # push your rebased branch to GitHub.
```

Periodically, you can apply the latest package updates.

```
$ sudo nix-channel --list               # check your nixpkgs channel subscription
$ sudo nixos-rebuild switch --upgrade   # update all installed packages
```

Current nixpkgs substriction is to the latest stable channel, `nixos-16.09`.

```
$ sudo nix-channel --add https://nixos.org/channels/nixos-16.09 nixos
```
