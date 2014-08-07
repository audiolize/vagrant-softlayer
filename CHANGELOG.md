## 0.3.3 (unreleased)

ENHANCEMENTS:

  - Add parallel execution capability.
  - Add configuration variables for provision and rebuild timeout.
  - Use builtin synced folders if available.

## 0.3.2 (August 1, 2014)

ENHANCEMENTS:

  - Add ability to specify vlans by name or qualified name.
  - Add vagrant-softlayer-vlans contrib tool.
  - Add ability to force private IP address usage.
  - Add quick start guide and Vagrant Cloud boxes.

BUG FIXES:

  - Fix crash on destroy/rebuild when the instance don't exist.

## 0.3.1 (June 3, 2014)

BUG FIXES:

  - Lock down softlayer_api gem to 1.0.x

## 0.3.0 (April 15, 2014)

NEW FEATURES:

  - Add selection of disk sizes for templates.
  - Add selection of block devices by id.
  - Add vagrant-softlayer-boxes contrib tool for creating boxes.
  - Add suspend/resume commands.

## 0.2.0 (December 5, 2013)

NEW FEATURES:

  - Automatic joining of local load balancers.

## 0.1.0 (November 18, 2013)

  - Initial release.
