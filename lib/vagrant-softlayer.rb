require "pathname"
require "softlayer_api"
require "vagrant-softlayer/plugin"

module VagrantPlugins
  module SoftLayer
    API_PRIVATE_ENDPOINT = ::SoftLayer::API_PRIVATE_ENDPOINT
    API_PUBLIC_ENDPOINT  = ::SoftLayer::API_PUBLIC_ENDPOINT

    lib_path = Pathname.new(File.expand_path("../vagrant-softlayer", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Config, lib_path.join("config")
    autoload :Errors, lib_path.join("errors")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
