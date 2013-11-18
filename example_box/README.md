# Vagrant SoftLayer Example Box

Vagrant providers each require a custom provider-specific box format.
This folder shows the example contents of a box for the `softlayer` provider.
To turn this into a box:

```
$ tar cvzf softlayer.box ./metadata.json [./Vagrantfile]
```

A Vagrantfile with default configuration values for SoftLayer could be added. 
These defaults can easily be overwritten by higher-level
Vagrantfiles (such as project root Vagrantfiles).
