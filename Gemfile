source 'https://rubygems.org'

gemspec

# Warning: Hack below.
#
# Add the current project gem to the "plugins" group
dependencies.find { |dep| dep.name == "vagrant-softlayer" }.instance_variable_set(:@groups, [:default, :plugins])

group :development do
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git"
end
