# Vagrant SoftLayer Provider

<span class="badges">
[![Gem Version](https://badge.fury.io/rb/vagrant-softlayer.png)](http://badge.fury.io/rb/vagrant-softlayer)
[![Code Climate](https://codeclimate.com/github/audiolize/vagrant-softlayer.png)](https://codeclimate.com/github/audiolize/vagrant-softlayer)
</span>

This is a [Vagrant](http://www.vagrantup.com) plugin that adds a [SoftLayer](http://www.softlayer.com)
provider to Vagrant, allowing Vagrant to control and provision SoftLayer CCI instances.

**NOTE:** This plugin work with Vagrant 1.3+, altough Vagrant 1.4+ is strongly advised.

## Features

* Basic lifecycle (boot, halt, reboot, suspend, resume) of SoftLayer CCI instances.
* OS reload on a CCI (`vagrant rebuild`).
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.

## Installation

> **NOTE**
>
> If you're using Vagrant 1.3, you need to [Set the SSL_CERT_FILE environment variable](https://github.com/audiolize/vagrant-softlayer/wiki/The-SSL_CERT_FILE-environment-variable) first.

Installation is performed in the prescribed manner for Vagrant 1.1+ plugins.
After installing, `vagrant up` and specify the `softlayer` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-softlayer
...
$ vagrant up --provider=softlayer
...
```

Of course prior to doing this, you'll need to obtain an SoftLayer-compatible
box file for Vagrant.

## Box File Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `softlayer` boxes. You can view an example box in
the `example_box/` directory. That directory also contains instructions
on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

This provider exposes quite a few provider-specific configuration options:

### Authentication

Parameter      | Description                          | Default                            | Required
-------------- | ------------------------------------ | ---------------------------------- | --------
`api_key`      | The API key for accessing SoftLayer  |                                    | yes
`endpoint_url` | The endpoint SoftLayer API url       | SoftLayer::API_PUBLIC_ENDPOINT     | yes
`username`     | The username for accessing SoftLayer |                                    | yes

> **NOTE**
>
> In place of the API key and username you can use environment variables, respectively `SL_API_KEY` and `SL_USERNAME`.

### DNS Management

If the DNS zone of the configured domain is hosted by SoftLayer, you can automatically manage it.

Parameter    | Description                           | Default | Required
------------ | ------------------------------------- | ------- | --------
`manage_dns` | Add/remove A record on create/destroy | false   | no

### Join Local Load Balancers

See [Join load balancers](https://github.com/audiolize/vagrant-softlayer/wiki/Join-load-balancers).

### Instance Configuration

Parameter           | Description                                                                      | Default                 | Required
------------------- | -------------------------------------------------------------------------------- | ----------------------- | --------
`api_timeout`       | The timeout when accessing the SoftLayer API                                     | 60                      | no
`datacenter`        | Datacenter shortname                                                             | First available         | no
`dedicated`         | Allocate a dedicated CCI (non-shared host)                                       | false                   | no
`disk_capacity`     | The capacity of each disk                                                        |                         | no **
`domain`            | The domain of the instance                                                       |                         | yes
`force_private_ip`  | Force the use of private IP for CCI communication even if public IP is available | false                   | no
`hostname`          | The hostname of the instance                                                     |                         | yes *
`hourly_billing`    | Hourly billing type (false for monthly)                                          | true                    | no
`image_guid`        | The global identifier for the compute or flex image to use                       |                         | no **
`local_disk`        | Use a local disk (false for SAN)                                                 | true                    | no
`max_memory`        | The amount of RAM of the instance in Mb                                          | 1024                    | no
`network_speed`     | Network port speed in Mbps                                                       | 10                      | no
`operating_system`  | The instance operating system identifier                                         | UBUNTU_LATEST           | no **
`post_install`      | URI of Post-install script to download                                           |                         | no
`private_only`      | Only create access to the private network                                        | false                   | no
`provision_timeout` | The amount of time in seconds to wait for provisioning to complete               | 1200                    | no
`rebuild_timeout`   | The amount of time in seconds to wait for rebuilding to complete                 | 1200                    | no
`ssh_key`           | ID or label of the SSH key(s) to provision                                       |                         | yes
`start_cpus`        | The number of processors of the instance                                         | 1                       | no
`user_data`         | User defined metadata string                                                     |                         | no
`vlan_private`      | The ID, name or qualified name of the private VLAN                               | Automatically generated | no
`vlan_public`       | The ID, name or qualified name of the public VLAN                                | Automatically generated | no

\* The `hostname` could be specified either using `config.vm.hostname` or the provider parameter.

\** When defining the instance you can either specify an `image_guid` or `operating_system` with optional `disk_capacity`.

These can be set like typical provider-specific configuration:

```
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :softlayer do |sl|
    sl.api_key  = "foo"
    sl.username = "bar"
    sl.ssh_key  = "Vagrant insecure key"
  end
end
```

## OS Reload

Reload of an instance's operating system is performed with the `vagrant rebuild` command.
The primary disk of the instance will be formatted and a fresh copy of the underlying OS
will be applied. Note that only `ssh_key` and `post_install` parameter will be read
during rebuild, all the other parameters will be ignored. Provisioners will always run
after rebuild.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the SoftLayer provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell, ansible,
chef, and puppet) to work!

## Other Examples

### Multiple disks

The `disk_capacity` parameter accepts an hash with the following structure:

```
{
  disk_id => disk_size,
  disk_id => disk_size,
  ...
}
```

Disk ID 1 is reserved is reserved for swap space, in the following example two disks
of 25Gb and 100Gb will be provisioned:

```
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :softlayer do |sl, override|
    # ... other stuff

    sl.disk_capacity = { 0 => 25, 2 => 100 }
  end
end
```

### Override SSH Username

If you're running Vagrant with an user different from root, probably you need
to override the username used for ssh connection. You can do it using the standard
Vagrant syntax:

```
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :softlayer do |sl, override|
    # ... other stuff

    override.ssh.username = "root"
  end
end
```

### Multiple SSH keys

Multiple SSH keys to be provisioned could be specified using an array:

```
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :softlayer do |sl|
    sl.api_key  = "foo"
    sl.username = "bar"
    # ssh_keys is just an alias of ssh_key
    sl.ssh_keys = ["Vagrant insecure key", "My personal key"]
  end
end
```

Also, a bunch of aliases for the `ssh_key` parameter are provided for better semantic:

* `ssh_keys`
* `ssh_key_id`
* `ssh_key_ids`
* `ssh_key_name`
* `ssh_key_names`

## Quick Start Guide

For those new to Vagrant, see the [Quick Start Guide](https://github.com/audiolize/vagrant-softlayer/blob/master/QUICKSTART.md).

## Development

To work on the `vagrant-softlayer` plugin, clone this repository out, and use
[Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
and add the following line to your `Vagrantfile`:

```
Vagrant.require_plugin "vagrant-softlayer"
```

Use bundler to execute Vagrant:

```
$ bundle exec vagrant up --provider=softlayer
```

## Credits

Emiliano Ticci (@emyl)
Julio Lajara (@ju2wheels)

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/audiolize/vagrant-softlayer/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

