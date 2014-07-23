# vagrant-softlayer Contrib

Miscellaneous contributions which assist people in using vagrant-softlayer will
make their way into this directory. An up-to-date list of short descriptions
for each item will be kept below.

## List of Contrib Items

* `vagrant-softlayer-boxes` - Vagrant box creation tool which allows you to create
starter boxes from those offered in the SoftLayer API or from public/private compute
or flex images associated with your SoftLayer account.
* `vagrant-softlayer-vlans` - SoftLayer vlan tool which allows you to list the data
for all SoftLayer vlans associated with your account that are usable for assigning to
CCI's during `vagrant-softlayer` provisioning. It provides the id, name, and qualified
name of vlans that can be used with the `vlan_private` and `vlan_public`
`vagrant-softlayer` settings.