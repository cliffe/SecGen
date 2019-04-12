# Creating new SecGen bases

We encourage you to use the existing bases when developing scenarios. Introducing new base boxes require careful thought and testing of modules for compatibility. This guide is mostly indended for those who wish to extend SecGen onto further VDI platforms (in addition to VirtualBox, and oVirt), which involves recreating our existing base images on these other platforms.

When creating base images for SecGen, follow [guidelines on creating Vagrant base boxes](https://www.vagrantup.com/docs/boxes/base.html), with these additional considerations.

## Make sure these packages are installed on every base
- puppet
- curl
- wget
- rsync
- vim
- psmisc
- sudo

Install VM guest tools software, to enable copy-paste between VMs, graphics, etc.

Occasionally we apt-get update; apt-get upgrade. This can be required to avoid package repo certificates from expiring; however, this does run the risk of breaking modules.

## Avoid SecGen leaving extra files on the VMs
You should have these directories mounted as tmpfs, so that the files used by Vagrant to provision the VMs (including puppet files, SecGen module names, etc), don't get accidentally left on the VMs that are generated.
- /tmp/
- /vagrant/

This can be achieved via /etc/fstab:

```
tmpfs    /tmp    tmpfs    defaults,noatime   0  0
tmpfs    /vagrant    tmpfs    defaults,noatime   0  0
```

## After making changes

In the VM:

```bash
sudo apt-get clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
history -c
history -w
```

Finally package to upload:
vagrant package --base vmname --output packaged.box
