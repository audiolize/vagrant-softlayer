begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant SoftLayer plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.3.0"
  raise "The Vagrant SoftLayer plugin is only compatible with Vagrant 1.3+"
end

module VagrantPlugins
  module SoftLayer
    class Plugin < Vagrant.plugin("2")
      name "SoftLayer"
      description <<-DESC
      This plugin installs a provider that allows Vagrant to manage
      SoftLayer CCI.
      DESC

      command(:rebuild) do
        require_relative 'command/rebuild'
        Command::Rebuild
      end

      config(:softlayer, :provider) do
        require_relative "config"
        Config
      end

      provider(:softlayer, :parallel => true) do
        init_logging
        init_i18n

        require_relative "provider"
        Provider
      end

      # This initializes the I18n load path so that the plugin specific
      # transations work.
      def self.init_i18n
        I18n.load_path << File.expand_path("locales/en.yml", SoftLayer.source_root)
        I18n.reload!
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.init_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_softlayer")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
