# nixos-config

NixOS configuration files for VirtualBox and BYO development machines. See https://nixos.org.

The machine defined in `machines/ga/configuration.nix` is continuously built
into an OVF (Open Virtualization Format) appliance and uploaded into
http://s3-ap-southeast-2.amazonaws.com/geodesy-nixos/.

## Getting Started

### Download and import the latest OVF appliance
```
$ wget http://s3-ap-southeast-2.amazonaws.com/geodesy-nixos/nixos-16.03.1168.44b1d6b-x86_64-linux.ova
$ VBoxManager import nixos-16.03.1168.44b1d6b-x86_64-linux.ova
```
### Start the VM
```
$ VBoxManager list vms                  # print the name and UUID of the imported the VM
$ VirtualBox --startvm <vmname|uuid>
```
### Login and customise the VM
```
$ ssh -p 4022 guest@localhost           # password is "change-me"
$ cd /etc/nixos
$ git clone https://github.com/GeoscienceAustralia/nixos-config .
$ ln -s machine/ga/configuration.nix
$ git checkout -b <your-branch>
$ vim configuration.nix                 # set your username, customise the configuration
$ sudo nixos-rebuild switch             # build the new configuration and switch to it
$ sudo su - <username>                  # login as your new user
$ passwd                                # change your password

$ ssh-keygen                            # generate your private and public SSH keys
                                        # upload your public SSH key to GitHub
                                       
# use SSH instead of HTTPS 
$ git remote remove origin
$ git remote add origin git@github.com:GeoscienceAustralia/nixos-config

# commit your changes and push them to GitHub
$ git add machine/ga/configuration.nix
$ git commit -m"Customise"
$ git push -u origin <your-branch>      # push your branch to GitHub

```
## Keeping Up-to-date

Periodically, you can rebase your branch onto the latest changes from master.

```
$ git fetch origin master:master        # Pull in the latest changes from master
$ git rebase master                     # rebase your branch
$ sudo nixos-rebuild switch             # Switch to the new configuration
$ git push -f                           # push your rebased branch to GitHub.
```



