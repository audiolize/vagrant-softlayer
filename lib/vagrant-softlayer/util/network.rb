module VagrantPlugins
  module SoftLayer
    module Util
      module Network
        # Gets hostname of the instance starting from the environment.
        def hostname(env)
          env[:machine].provider_config.hostname || env[:machine].config.vm.hostname
        end

        # Gets IP address of the instance starting from the environment.
        #
        # Returns the private IP address if the instance has been
        # defined as private only, the public IP address otherwise.
        def ip_address(env)
          ip_address_record(env)[:address]
        end

        # Gets IP address ID of the instance starting from the environment.
        #
        # Returns the private IP address ID if the instance has been
        # defined as private only, the public IP address ID otherwise.
        def ip_address_id(env)
          ip_address_record(env)[:id]
        end

        # Gets IP address record of the instance starting from the environment.
        #
        # Returns an hash with the following structure:
        #
        # :address
        # :id
        #
        # Returns the private IP address record if the instance has been
        # defined as private only, the public IP address record otherwise
        # unless the force_private_ip override is true.
        def ip_address_record(env)
          data_type = env[:machine].provider_config.private_only ? "primaryBackendNetworkComponent" : "primaryNetworkComponent"
          data_type = "primaryBackendNetworkComponent" if env[:machine].provider_config.force_private_ip
          mask      = { data_type => { "primaryIpAddressRecord" => ["id", "ipAddress"] } }
          record    = sl_warden { env[:sl_machine].object_mask(mask).getObject }
          return {
            :address => record[data_type]["primaryIpAddressRecord"]["ipAddress"],
            :id      => record[data_type]["primaryIpAddressRecord"]["id"]
          }
        end

        # Returns SSH keys starting from the configuration parameter.
        #
        # In the configuration, each key could be passed either as an
        # id or as a label. The routine will detect this and lookup
        # the id if needed.
        #
        # The first parameter is the current environment.
        #
        # The second parameter is useful for returning: if it is set
        # the routine will return just the array of ids (this is needed,
        # as an example, for reloading OS), otherwise an hash is
        # returned (this latter case is needed instead for creating
        # an instance).
        def ssh_keys(env, ids_only = false)
          account  = ::SoftLayer::Service.new("SoftLayer_Account", env[:sl_credentials])
          acc_keys = sl_warden { account.object_mask("id", "label").getSshKeys }
          key_ids  = []
          Array(env[:machine].provider_config.ssh_key).each do |key|
            pattern = key.is_a?(String) ? "label" : "id"
            key_hash = acc_keys.find { |acc_key| acc_key[pattern] == key }
            raise Errors::SLSshKeyNotFound, :key => key unless key_hash
            key_ids << key_hash["id"]
          end
          return (ids_only ? key_ids : key_ids.map { |key_id| { :id => key_id } })
        end
      end
    end
  end
end
