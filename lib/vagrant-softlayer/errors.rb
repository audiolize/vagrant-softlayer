module VagrantPlugins
  module SoftLayer
    module Errors
      class VagrantSoftLayerError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_softlayer.errors")
      end

      class SLApiError < VagrantSoftLayerError
        error_key(:api_error)
      end

      class SLCertificateError < VagrantSoftLayerError
        error_key(:certificate_error)
      end

      class SLDNSZoneNotFound < VagrantSoftLayerError
        error_key(:dns_zone_not_found)
      end

      class SLLoadBalancerNotFound < VagrantSoftLayerError
        error_key(:load_balancer_not_found)
      end

      class SLSshKeyNotFound < VagrantSoftLayerError
        error_key(:ssh_key_not_found)
      end

      class SLVlanIdNotFound < VagrantSoftLayerError
        error_key(:vlan_id_not_found)
      end
    end
  end
end
