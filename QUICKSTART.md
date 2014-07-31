# vagrant-softlayer Quick Start Guide

This is quick start guide to setting up [Vagrant](http://www.vagrantup.com) and the `vagrant-softlayer`
plugin to build your first Cloud Computing Instance (CCI). While this guide will explain the process,
it is not intended as a replacement for existing documentation and you should always review the latest
documentation resources for more in depth coverage or updates as functionality changes quickly:

Resource                                                                                                                  | Description
------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
[Ruby](https://www.ruby-lang.org/en/)                                                                                     | Obligatory Ruby language documentation.
[Ruby Quick Start](https://www.ruby-lang.org/en/documentation/quickstart/)                                                | Ruby in 20 minutes quick start guide, as its essential to understand some Ruby basics to have a proper grasp for how [Vagrant](http://www.vagrantup.com) and `Vagrantfile`s work.
[SoftLayer Developer Network](http://sldn.softlayer.com/)                                                                 | SoftLayer API documentation.
[Vagrant](http://docs.vagrantup.com/v2/)                                                                                  | [Vagrant](http://www.vagrantup.com) documentation has a lot of sections but its worth a full read to understand what configuration options are available.
[Vagrant Cloud](https://vagrantcloud.com/)                                                                                | Source for Vagrant boxes.
[Vagrant GitHub Issues](https://github.com/mitchellh/vagrant/issues)                                                      | A lot of common issues and question are opened and answered here, this is more active than the Vagrant Google Group forum.
[Vagrant Google Group Forum](https://groups.google.com/forum/#!forum/vagrant-up)                                          | Like `Vagrant GitHub Issues`, this is another good location for finding common pitfalls, bugs, or getting help.
[Vagrant: Up and Running](http://www.amazon.com/Vagrant-Up-Running-Mitchell-Hashimoto/dp/1449335837)                      | [Vagrant](http://www.vagrantup.com) book by original dev released by O'Reilly.
[vagrant-softlayer](https://github.com/audiolize/vagrant-softlayer/)                                                      | Provides full documentation on available vagrant-softlayer settings.
[vagrant-softlayer Contrib Tools](https://github.com/audiolize/vagrant-softlayer/tree/master/contrib)                     | Provides overview of available tools to assist you with configuring and using `vagrant-softlayer`
[vagrant-softlayer Load Balancers Configuration](https://github.com/audiolize/vagrant-softlayer/wiki/Join-load-balancers) | `vagrant-softlayer` wiki page describing configuration for adding CCI to a SoftLayer Load Balancer.
[vagrantbox.es](http://www.vagrantbox.es/)                                                                                | Source for [Vagrant](http://www.vagrantup.com) boxes.
[veewee](https://github.com/jedi4ever/veewee)                                                                             | Veewe is a tool used to create non cloud [Vagrant](http://www.vagrantup.com) boxes.

## Vagrant History and Overiew

[Vagrant](http://www.vagrantup.com) is a wrapper around virtualization hypervisors (KVM, VirtualBox, VMWare, etc),
infrastructure as a server (IaaS) cloud providers/technology (OpenStack, SoftLayer, 
DigitalOcean, Amazon AWS, etc), and configuration management tools (Ansible, Chef,
Puppet, Salt, etc). While [Vagrant](http://www.vagrantup.com) was originally only designed to support VirtualBox,
through the use of extensive plugins its feature set has grown and continues to expand.

[Vagrant](http://www.vagrantup.com) configuration revolves around 3 major components that are used to define a CCI or
vm in general on any hypervisor:

### Providers:

Provider plugins allow [Vagrant](http://www.vagrantup.com) to abstract away the automation required
to create a virtual machine on a hypervisor in a way that allows you to specify both the resource
requirements of the virtual machine (such as memory, cpu, disk, networking, peripherals) but also
allow the use of hypervisor specific settings to be used for extra configuration.

### Provisioners:

Provisioner plugins allow [Vagrant](http://www.vagrantup.com) to abstract away the automation required
to perform tasks on the virtual machine once its created. Normally this would consist of either triggering
a configuration management tool, script, or action that then modifies the virtual machine.

### Boxes:

[Vagrant](http://www.vagrantup.com) uses boxes as means to provide a pre-configured base from which to create
virtual machine instances. A box is just a zip or tar archive which contains:

* JSON metadata file describing what provider the box supports, what version the box is and other details.
* `Vagrantfile` which preconfigures the virtual machine instance or provider with specific settings (all of which
can later be overriden).
* Virtual disk image files (vmdk, img, vdi, etc) for non cloud providers (such as VirtualBox, VMWare). Since
[Vagrant](http://www.vagrantup.com) doesnt actually build an OS from scratch using typical install media as is
done with a manual install, it uses the virtual disk image to effectively clone a machine starting point on the
hypervisor.

## Install Vagrant

[Download](http://www.vagrantup.com/downloads.html) the appropriate [Vagrant](http://www.vagrantup.com)
installer for your platform and install. 

## Install vagrant-softlayer

Open a terminal and run the following:

`vagrant plugin install vagrant-softlayer`

Alternatively you can also do a manual gem install if you manually download it from the RubyGems.org [vagrant-softlayer](http://rubygems.org/gems/vagrant-softlayer)
gem page:

`vagrant plugin install vagrant-softlayer-<version>.gem`

For developers wishing to extend and test `vagrant-softlayer`, a gem for manual install with your included changes
can built by running the following in the main `vagrant-softlayer` project directory:

`gem build vagrant-softlayer.gemspec`

## Install Vagrant Boxes

[Vagrant](http://www.vagrantup.com) boxes can be installed using a URI (file or web URL) for a box or a [Vagrant Cloud](https://vagrantcloud.com/)
box label used to download a box from that service.

Boxes can be created using the `vagrant-softlayer-boxes` tool located in the `contrib/` folder which is available at
`~/.vagrant.d/gems/gems/vagrant-softlayer-<version>/contrib/vagrant-softlayer-boxes` or Windows equivalent once you have
installed `vagrant-softlayer`.

If you would like to create boxes for non cloud providers, we recommend taking a look at [veewee](https://github.com/jedi4ever/veewee).

To simplify this guide and make manual box install optional, we have added boxes for SoftLayer OS templates to [Vagrant Cloud](https://vagrantcloud.com/):

Vagrant Cloud URI                   | Description
----------------------------------- | -----------------------------------------------------------------------------------------------------------------------------------------------------
ju2wheels/SL_CENTOS_5_32            | CentOS 5 32bit/i386
ju2wheels/SL_CENTOS_5_64            | CentOS 5 64bit/x86_64
ju2wheels/SL_CENTOS_6_32            | CentOS 6 32bit/i386
ju2wheels/SL_CENTOS_6_64            | CentOS 6 64bit/x86_64
ju2wheels/SL_CENTOS_LATEST_32       | Latest available CentOS 32bit/i386
ju2wheels/SL_CENTOS_LATEST_64       | Latest available CentOS 64bit/x86_64
ju2wheels/SL_CENTOS_LATEST          | Latest available CentOS
ju2wheels/SL_CLOUDLINUX_5_32        | CloudLinux 5 32bit/i386
ju2wheels/SL_CLOUDLINUX_5_64        | CloudLinux 5 64bit/x86_64
ju2wheels/SL_CLOUDLINUX_6_32        | CloudLinux 6 32bit/i386
ju2wheels/SL_CLOUDLINUX_6_64        | CloudLinux 6 64bit/x86_64
ju2wheels/SL_CLOUDLINUX_LATEST_32   | Latest available CloudLinux 32bit/i386
ju2wheels/SL_CLOUDLINUX_LATEST_64   | Latest available CloudLinux 64bit/x86_64
ju2wheels/SL_CLOUDLINUX_LATEST      | Latest available CloudLinux
ju2wheels/SL_DEBIAN_5_32            | Debian 5 32bit/i386
ju2wheels/SL_DEBIAN_5_64            | Debian 5 64bit/x86_64
ju2wheels/SL_DEBIAN_6_32            | Debian 6 32bit/i386
ju2wheels/SL_DEBIAN_6_64            | Debian 6 64bit/x86_64
ju2wheels/SL_DEBIAN_7_32            | Debian 7 32bit/i386
ju2wheels/SL_DEBIAN_7_64            | Debian 7 64bit/x86_64
ju2wheels/SL_DEBIAN_LATEST_32       | Latest available Debian 32bit/i386
ju2wheels/SL_DEBIAN_LATEST_64       | Latest available Debian 64bit/x86_64
ju2wheels/SL_DEBIAN_LATEST          | Latest available Debian
ju2wheels/SL_REDHAT_5_32            | Red Hat Enterprise Linux 5 32bit/i386
ju2wheels/SL_REDHAT_5_64            | Red Hat Enterprise Linux 5 64bit/x86_64
ju2wheels/SL_REDHAT_6_32            | Red Hat Enterprise Linux 6 32bit/i386
ju2wheels/SL_REDHAT_6_64            | Red Hat Enterprise Linux 6 64bit/x86_64
ju2wheels/SL_REDHAT_LATEST_32       | Latest available Red Hat Enterprise Linux 32bit/i386
ju2wheels/SL_REDHAT_LATEST_64       | Latest available Red Hat Enterprise Linux 64bit/x86_64
ju2wheels/SL_REDHAT_LATEST          | Latest available Red Hat Enterprise Linux
ju2wheels/SL_GENERIC                | Generic SoftLayer box with no OS template defined, you will have to explicity set `operating_system`/`disk_capacity` or `image_guid` in your provider
ju2wheels/SL_UBUNTU_10_32           | Ubuntu 10.04 LTS 32bit/i386
ju2wheels/SL_UBUNTU_10_64           | Ubuntu 10.04 LTS 64bit/x86_64
ju2wheels/SL_UBUNTU_12_32           | Ubuntu 12.04 LTS 32bit/i386
ju2wheels/SL_UBUNTU_12_64           | Ubuntu 12.04 LTS 64bit/x86_64
ju2wheels/SL_UBUNTU_14_32           | Ubuntu 14.04 LTS 32bit/i386
ju2wheels/SL_UBUNTU_14_64           | Ubuntu 14.04 LTS 64bit/x86_64
ju2wheels/SL_UBUNTU_8_32            | Ubuntu 8.04 LTS 32bit/i386
ju2wheels/SL_UBUNTU_8_64            | Ubuntu 8.04 LTS 64bit/x86_64
ju2wheels/SL_UBUNTU_LATEST_32       | Latest available Ubuntu 32bit/i386
ju2wheels/SL_UBUNTU_LATEST_64       | Latest available Ubuntu 64bit/x86_64
ju2wheels/SL_UBUNTU_LATEST          | Latest available Ubuntu 
ju2wheels/SL_VYATTACE_6.5_64        | Vyatta Community Edition 6.5 64bit/x86_64
ju2wheels/SL_VYATTACE_6.6_64        | Vyatta Community Edition 6.6 64bit/x86_64
ju2wheels/SL_VYATTACE_LATEST_64     | Latest available Vyatta Community Edition 64bit/x86_64
ju2wheels/SL_VYATTACE_LATEST        | Latest available Vyatta Community Edition
ju2wheels/SL_WIN_2003-DC-SP2-1_32   | Windows 2003 Datacenter Edition SP2 32bit
ju2wheels/SL_WIN_2003-DC-SP2-1_64   | Windows 2003 Datacenter Edition SP2 64bit
ju2wheels/SL_WIN_2003-ENT-SP2-5_32  | Windows 2003 Enterprise Edition SP2 32bit
ju2wheels/SL_WIN_2003-ENT-SP2-5_64  | Windows 2003 Enterprise Edition SP2 64bit
ju2wheels/SL_WIN_2003-STD-SP2-5_32  | Windows 2003 Standard Edition SP2 32bit
ju2wheels/SL_WIN_2003-STD-SP2-5_64  | Windows 2003 Standard Edition SP2 64bit
ju2wheels/SL_WIN_2008-DC-R2_64      | Windows 2008 R2 Datacenter Edition 64bit
ju2wheels/SL_WIN_2008-DC-SP2_32     | Windows 2008 Datacenter Edition SP2 32bit
ju2wheels/SL_WIN_2008-DC-SP2_64     | Windows 2008 Datacenter Edition SP2 64bit
ju2wheels/SL_WIN_2008-ENT-R2_64     | Windows 2008 R2 Enterprise Edition 64bit
ju2wheels/SL_WIN_2008-ENT-SP2_32    | Windows 2008 Enterprise Edition SP2 32bit
ju2wheels/SL_WIN_2008-ENT-SP2_64    | Windows 2008 Enterprise Edition SP2 64bit
ju2wheels/SL_WIN_2008-STD-R2_64     | Windows 2008 R2 Standard Edition 64bit
ju2wheels/SL_WIN_2008-STD-R2-SP1_64 | Windows 2008 R2 Standard Edition SP1 64bit
ju2wheels/SL_WIN_2008-STD-SP2_32    | Windows 2008 Standard Edition SP2 32bit
ju2wheels/SL_WIN_2008-STD-SP2_64    | Windows 2008 Standard Edition SP2 64bit
ju2wheels/SL_WIN_2012-DC_64         | Windows 2012 Datacenter Edition 64bit
ju2wheels/SL_WIN_2012-STD_64        | Windows 2012 Standard Edition 64bit
ju2wheels/SL_WIN_LATEST_32          | Latest available Windows 32bit
ju2wheels/SL_WIN_LATEST_64          | Latest available Windows 64bit
ju2wheels/SL_WIN_LATEST             | Latest available Windows

Install box from URI:
`vagrant box add BOXNAME URI`

Install box from [Vagrant Cloud](https://vagrantcloud.com/):
`vagrant box add 'USERNAME/BOXNAME'`

## Vagrant Box Standards vs SoftLayer Standards

When creating or using [Vagrant](http://www.vagrantup.com), the accepted community standard is that
the image be built with a default of having a `vagrant` user, with `vagrant` as the password, and
the [Vagrant insecure public key](https://github.com/mitchellh/vagrant/blob/master/keys/vagrant.pub)
applied to the `vagrant` user for ssh (the private key is always available to vagrant under
`~/.vagrant.d/insecure_private_key`).

Since SoftLayer doesnt really use [Vagrant](http://www.vagrantup.com), their image standards are bit
different. As shown in example template below, it is necessary to change the default user for the OS
you are using from `vagrant` to `root` (in the case of Linux).

If you do not want to use password based logins, you will also have to set your public ssh keys in
your SoftLayer portal, assign the name labels you set to `sl.ssh_keys`, and the path to their equivalent
private key half in `cci.ssh.private_key_path`.

## Working with a Vagrantfile to define CCI(s)

A `Vagrantfile` is the "configuration" file used by [Vagrant](http://www.vagrantup.com) when performing
actions against a virtual machine. Although its used as a configuration file, it is really a standard
Ruby file and anything that can be done in a normal Ruby script can also be accomplished in the 
`Vagrantfile`.

A `Vagrantfile` supports two styles of virtual machine definitions, one supports a single virtual machine
and the other supports specifiying the definition of multiple virtual machines in a single file.

Single Virtual Machine:
```
Vagrant.configure("2") do |config|
  # ... vm settings

  config.vm.provider :softlayer do |sl|
    sl.api_key  = "foo"
    sl.username = "bar"
    sl.ssh_key  = "Vagrant insecure key"
  end
end
```

Multiple Virtual Machines:
```
Vagrant.configure("2") do |config|
  # ... shared vm settings

  config.vm.define "sl_cci_shorthostname" do |cci|
    cci.vm.provider :softlayer do |sl|
      sl.api_key  = "foo"
      sl.username = "bar"
      sl.ssh_key  = "Vagrant insecure key"
    end
  end

  config.vm.define "sl_cci2_shorthostname" do |cci2|
    cci2.vm.provider :softlayer do |sl|
      sl.api_key  = "foo"
      sl.username = "bar"
      sl.ssh_key  = "Vagrant insecure key"
    end
  end
end
```

Lastly, we provide what a more complete template of what a Vagrantfile might contain when creating a CCI:

```
Vagrant.require_version ">= 1.5.2"

Vagrant.configure(2) do |config|
  #See http://docs.vagrantup.com/v2/vagrantfile/vagrant_settings.html
  config.vagrant.host = :detect
  
  config.vm.define "sl_cci_shortname" do |cci|
    #See http://docs.vagrantup.com/v2/vagrantfile/index.html
    cci.vm.box                        = "ju2wheels/SL_GENERIC"
    cci.vm.hostname                   = "sl-vagrant-cci"
    #cci.vm.boot_timeout               = 300
    #cci.vm.box_check_update           = false
    #cci.vm.box_download_checksum      = nil
    #cci.vm.box_download_checksum_type = nil
    #cci.vm.box_download_client_cert   = nil
    #cci.vm.box_download_insecure      = false
    #cci.vm.box_url                    = "https://vagrantcloud.com/ju2wheels/SL_GENERIC/version/1/provider/softlayer.box"
    #cci.vm.box_version                = ">=0"
    #cci.vm.graceful_halt_timeout      = 300
    #cci.vm.guest                      = :linux
    #cci.vm.usable_port_range          = 2200..2250
    
    #See http://docs.vagrantup.com/v2/vagrantfile/ssh_settings.html
    cci.ssh.forward_agent             = true
    cci.ssh.forward_x11               = false
    #cci.ssh.guest_port                = 22
    #cci.ssh.host                      = nil #Normally determined by provider
    #cci.ssh.insert_key                = true
    #cci.ssh.password                  = nil
    #cci.ssh.port                      = 22
    #cci.ssh.private_key_path          = [ File.expand_path("~/.ssh/id_rsa") ]
    #cci.ssh.pty                       = false #Warning this setting is not recommended and can break things, recommended to create flex image with sudoers fixed for problematic distros
                                               #See https://github.com/audiolize/vagrant-softlayer/issues/11
    #cci.ssh.shell                     = "bash -l"
    #cci.ssh.username                  = "vagrant"

    #Windows specific config options for vagrant-windows plugin
    #cci.windows.halt_check_interval   = 1 if Vagrant.has_plugin?("vagrant-windows")
    #cci.windows.halt_timeout          = 30 if Vagrant.has_plugin?("vagrant-windows")
    cci.windows.set_work_network      = true if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.guest_port              = 5985 if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.host                    = "localhost" if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.max_tries               = 20 if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.password                = "vagrant" if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.port                    = 5985 if Vagrant.has_plugin?("vagrant-windows")
    #cci.winrm.timeout                 = 1800 if Vagrant.has_plugin?("vagrant-windows")
    cci.winrm.username                = "vagrant" if Vagrant.has_plugin?("vagrant-windows")

    #See http://docs.vagrantup.com/v2/networking/index.html
    #cci.vm.network :forwarded_port, guest: 22, guest_ip: nil, host:2222, host_ip: nil, protocol: "tcp", auto_correct: true

    #Always put the private network before the public so it matches SoftLayer (when using VirtualBox or other hypervisor), eth0 is private and eth1 public, they are created in order provided
    #cci.vm.network :private_network, type: "dhcp", ip: nil, auto_config: true, virtualbox__intnet: true
    #cci.vm.network :private_network, type: "static", ip: "192.168.10.5", auto_config: true, virtualbox__intnet: "internalnetname"
    #cci.vm.network :public_network, type: "dhcp", ip: nil, auto_config: true, virtualbox__intnet: false, bridge: "wlan0"
    #cci.vm.network :public_network, type: "static", ip: '192.168.1.20', auto_config: true, virtualbox__intnet: false, bridge: "wlan0"

    #See http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
    #Guest must have NFS, if using VirtualBox there must be a private network with static IP present, may require root privs (it will prompt)
    #cci.vm.synced_folder ".", "/vagrant", disabled: false, create: false, group: "root", owner: "root", type: "nfs", nfs_udp: true, nfs_version: 3, mount_options: []
    #cci.vm.synced_folder ".", "/vagrant", disabled: false, create: false, group: "root", owner: "root", type: "rsync", rsync__args: ["--verbose", "--archive", "--delete", "-z"], 
    #                          rsync__auto: true, rsync__exclude: [ ".vagrant", ".git"], mount_options: []
    #cci.vm.synced_folder ".", "/vagrant", disabled: false, create: false, group: "root", owner: "root", type: "smb", smb_host: nil, smb_username: nil, smb_password: nil, mount_options: []

    cci.vm.provider :softlayer do |sl, cci_override|
      #Override the default setting only if using this provider
      cci_override.vm.box       = "ju2wheels/SL_CENTOS_6_64"
      cci_override.ssh.username = "root"

      #Note: If you use SL_GENERIC box you must set sl.image_guid or sl.operating_system/sl.dis_capacity, otherwise it is pre-set for you by the box

      sl.api_key                   = ENV["SL_API_KEY"]
      #sl.api_timeout               = 60
      #sl.datacenter                = nil  #Use first available
      #sl.dedicated                 = false
      #sl.disk_capacity             = { 0 => 25 } # { disk_num => capacity_gb }, disk 1 reserved for swap by SoftLayer dont use
      sl.domain                    = ENV["SL_DOMAIN"]
      #sl.endpoint_url              = SoftLayer::API_PUBLIC_ENDPOINT
      #sl.force_private_ip          = false
      sl.hostname                  = cci.vm.hostname
      #sl.hourly_billing            = true
      #sl.image_guid                = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE" #Dont use this with sl.operating_system/sl.disk_capacity, they are mutually exclusive
      sl.local_disk                = false
      #sl.manage_dns                = false
      #sl.max_memory                = 1024
      #sl.network_speed             = 10
      #sl.operating_system          = "SL_CENTOS_6_64" #Set in box, here for override or if you used SL_GENERIC, see contrib/vagrant-softlayer-boxes of vagrant-softlayer plugin for box generator
      #sl.post_install              = nil #URL for post install script
      #sl.private_only              = false
      #sl.provision_timeout         = 1200
      #sl.rebuild_timeout           = 1200
      sl.ssh_keys                  = [ "SL-root-pk" ]
      #sl.start_cpus                = 1
      #sl.user_data                 = nil
      sl.username                  = ENV["SL_API_USERNAME"] || ENV['USER'] || ENV['USERNAME']   
      #sl.vlan_private              = nil #Automatically generated, override to vlan number string otherwise, see contrib/vagrant-softlayer-vlans tool for list of acceptable vlan values
      #sl.vlan_public               = nil #Automatically generated, override to vlan number string otherwise

      #Join a load balancer, see https://github.com/audiolize/vagrant-softlayer/wiki/Join-load-balancers for more options
      #sl.join_load_balancer vip: "1.1.1.1", port: 443, method: "Round Robin", type: "TCP" do |service|
        #service.destination_port = 443
        #service.health_check = "Ping"
        #service.weight = 2
      #end
    end if Vagrant.has_plugin?("SoftLayer")

    #cci.vm.provision :file do |fileupload|
    #  fileupload.source      = "/tmp/local_example.txt"
    #  fileupload.destination = "/tmp/uploaded_vm_example.txt"
    #end

    #cci.vm.provision :shell do |shellscript|
      #Use the id to override it somewhere else, and preserve_order ensures it gets executed at the point
      #where it was originally defined instead of where it was overriden.
    #  shellscript.inline = "/bin/echo -n 'hello_world' > /dev/null", id: "helloworld", preserve_order: true
    #end
  end
end
```

## Building the CCI using the Vagrantfile

Once you have a `Vagrantfile` built up the last step is building your CCI. However, before running the build command,
there are few important environment variables that [Vagrant](http://www.vagrantup.com) uses which you should be
aware of:

Environment Variable        | Recommended Value                                         | Description
--------------------------- | --------------------------------------------------------- | -----------
VAGRANT_CWD                 | UNSET, set as needed                                      | Changes the default CWD where [Vagrant](http://www.vagrantup.com) looks for a `Vagrantfile`
VAGRANT_DEFAULT_PROVIDER    | "softlayer"                                               | Sets the default provider so you dont have to manually specify it as a CLI option to [Vagrant](http://www.vagrantup.com).
VAGRANT_DEFAULT_PROVISIONER | UNSET, set as needed                                      | Sets the default provisioner so you dont have to manually specify it as a CLI option to [Vagrant](http://www.vagrantup.com).
VAGRANT_DOTFILE_PATH        | "~/.vagrant.d/state/" (Must make this directory manually) | [Vagrant](http://www.vagrantup.com) will normally create a `.vagrant` directory in the CWD to maintain state, to avoid this as we move through different directories with different `Vagrantfile`s, we pin it to the user [Vagrant](http://www.vagrantup.com) directory.
VAGRANT_HOME                | "~/.vagrant.d/"                                           | The default directory where [Vagrant](http://www.vagrantup.com) will install plugins on a per user basis and maintain any related files.
VAGRANT_LOG                 | UNSET, set as needed                                      | Sets the default [Vagrant](http://www.vagrantup.com) log level
VAGRANT_VAGRANTFILE         | UNSET, set as needed                                      | Sets the name of the `Vagrantfile` [Vagrant](http://www.vagrantup.com) will use as a configuration file. Can be changed with each execution of [Vagrant](http://www.vagrantup.com) to allow you to maintain multiple `Vagrantfile`s of different names in the same directory.

When you run your CCI build command, a few things will happen internally in [Vagrant](http://www.vagrantup.com) (see [Load Order and Merging](http://docs.vagrantup.com/v2/vagrantfile/index.html) ):

1. [Vagrant](http://www.vagrantup.com) will load the `Vagrantfile` associated with the box you specified (if any exists).
2. [Vagrant](http://www.vagrantup.com) will load a `Vagrantfile` from your `VAGRANT_HOME` and merge it ontop of the last (if any esits).
3. [Vagrant](http://www.vagrantup.com) will load a `Vagrantfile` from `VAGRANT_CWD` and merge it ontop of last (if any exists).
4. [Vagrant](http://www.vagrantup.com) then executes the requested command using the merged configuration.

Now finally to build your CCI:
`vagrant up`