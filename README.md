# Vagrant SoftLayer Provider

[![Code Climate](https://codeclimate.com/github/audiolize/vagrant-softlayer.png)](https://codeclimate.com/github/audiolize/vagrant-softlayer)

This is a [Vagrant](http://www.vagrantup.com) 1.3+ plugin that adds a [SoftLayer](http://www.softlayer.com)
provider to Vagrant, allowing Vagrant to control and provision SoftLayer CCI instances.

**NOTE:** This plugin requires Vagrant 1.3+

## Features

* Basic lifecycle (boot, halt, reboot) of SoftLayer CCI instances.
* OS reload on a CCI (`vagrant rebuild`).
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.

## Installation

### Set the `SSL_CERT_FILE` environment variable

If you intend to use the public API endpoint, which is the default, you have to
set the `SSL_CERT_FILE` environment variable.

The *net/http* library of the Vagrant's embedded ruby does **not**
check the validity of an SSL certificate during a TLS handshake. This breaks all
the calls to the SoftLayer API, making the plugin unusable.

For fixing this issue, you have to make ruby aware of a certificate authority
bundle by setting `SSL_CERT_FILE`:

**Linux**

* To set this in your current command prompt session, type:

  `export SSL_CERT_FILE=/opt/vagrant/embedded/cacert.pem`

* To make this a permanent setting, add this in `.bashrc` or `.profile`.

**Mac OS X**

* To set this in your current command prompt session, type:

  `export SSL_CERT_FILE=/Applications/Vagrant/embedded/cacert.pem`

* To make this a permanent setting, add this in `/etc/launchd.conf`.

**Windows**

* To set this in your current command prompt session, type:

  `set SSL_CERT_FILE=C:\HashiCorp\Vagrant\embedded\cacert.pem`

* To make this a permanent setting, add this in your [control panel](http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/environment_variables.mspx?mfr=true).

### Plugin installation

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

Parameter          | Description                                 | Default                 | Required
------------------ | ------------------------------------------- | ----------------------- | --------
`datacenter`       | Datacenter shortname                        | First available         | no
`dedicated`        | Allocate a dedicated CCI (non-shared host)  | false                   | no
`domain`           | The domain of the instance                  |                         | yes
`hostname`         | The hostname of the instance                |                         | yes *
`hourly_billing`   | Hourly billing type (false for monthly)     | true                    | no
`local_disk`       | Use a local disk (false for SAN)            | true                    | no
`max_memory`       | The amount of RAM of the instance in Mb     | 1024                    | no
`network_speed`    | Network port speed in Mbps                  | 10                      | no
`operating_system` | The instance operating system identifier    | UBUNTU_LATEST           | no
`post_install`     | URI of Post-install script to download      |                         | no
`private_only`     | Only create access to the private network   | false                   | no
`ssh_key`          | ID or label of the SSH key(s) to provision  |                         | yes
`start_cpus`       | The number of processors of the instance    | 1                       | no
`user_data`        | User defined metadata string                |                         | no
`vlan_private`     | The ID of the private VLAN                  | Automatically generated | no
`vlan_public`      | The ID of the public VLAN                   | Automatically generated | no

\* The `hostname` could be specified either using `config.vm.hostname` or the provider parameter.

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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/audiolize/vagrant-softlayer/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

