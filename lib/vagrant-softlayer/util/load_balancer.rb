module VagrantPlugins
  module SoftLayer
    module Util
      # This mixin contains utility methods for load balancer management.
      module LoadBalancer
        # Whether load balancer management is enabled or not.
        def enabled?
          if @env[:machine].provider_config.load_balancers.empty?
            @logger.debug("No load balancer has been defined. Going ahead.")
            return false
          end

          # Currently we don't do load balancing for private machines.
          if @env[:machine].provider_config.private_only
            @logger.info("Load balancing doesn't work for private machines. Going ahead.")
            return false
          end
          true
        end

        # Get existing stuff.
        def read_load_balancers
          mask    = [
            "id",
            "ipAddress.ipAddress",
            "virtualServers.serviceGroups.services.groupReferences",
            "virtualServers.serviceGroups.services.healthChecks"
          ]
          @logger.debug("Looking for existing load balancers.")
          @load_balancers = sl_warden { @services["Account"].object_mask(mask).getAdcLoadBalancers }
          @logger.debug("Got load balancer configuration:")
          @logger.debug("-- #{@load_balancers}")
        end

        # For each load balancer, check if total connections
        # are less than 100% and, if so, rebalance the allocations.
        def rebalance!
          read_load_balancers
          
          @load_balancers.each do |load_balancer|
            next if load_balancer["virtualServers"].empty?
            next if 100 == load_balancer["virtualServers"].inject(0) { |sum, vs| sum += vs["allocation"] }

            # Create allocation slots.
            count      = load_balancer["virtualServers"].count
            allocation = [100 / count] * count
            (100 % count).times { |i| allocation[i] += 1 }

            # Rebalance allocations.
            load_balancer["virtualServers"].each do |vs|
              vs["allocation"] = allocation.pop
            end

            # Update the VIP object.
            @logger.debug("Rebalancing VIP #{load_balancer['id']}")
            @logger.debug("-- #{load_balancer}")
            @services["VirtualIpAddress"].object_with_id(load_balancer["id"]).editObject("virtualServers" => load_balancer["virtualServers"])
          end
        end

        # Initial setup.
        def setup
          # A plethora of service objects is required for managing
          # load balancers. We instanciate'em all here.
          @services = {
            "Account" => ::SoftLayer::Service.new("SoftLayer_Account", @env[:sl_credentials])
          }
          [
            "Health_Check_Type",
            "Routing_Method",
            "Routing_Type",
            "Service",
            "Service_Group",
            "VirtualIpAddress",
            "VirtualServer"
          ].each do |service|
            @services[service] = ::SoftLayer::Service.new(
              "SoftLayer_Network_Application_Delivery_Controller_LoadBalancer_#{service}",
              @env[:sl_credentials]
            )
          end

          # We create enumerations for the various configurables.
          @enums = {}
          [
            "Health_Check_Type",
            "Routing_Method",
            "Routing_Type"
          ].each do |service|
            {}.tap do |enum|
              sl_warden { @services[service].getAllObjects }.each do |record|
                enum[record["name"].upcase] = record["id"]
              end
              @enums[service] = enum
            end
          end

          read_load_balancers
        end
      end
    end
  end
end
