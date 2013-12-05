module VagrantPlugins
  module SoftLayer
    module Action
      # Look for defined load balancers and perform join operations.
      class JoinLoadBalancer
        include Util::LoadBalancer
        include Util::Network
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::join_load_balancer")
        end

        def call(env)
          @env = env

          if enabled?
            setup
            prepare
            join!
            rebalance!
          end

          @app.call(@env)
        end

        def append_service_group(cfg, idx)
          {}.tap do |virtual_server|
            virtual_server["allocation"]    = 1
            virtual_server["port"]          = cfg[:port]
            virtual_server["serviceGroups"] = [
              {
                "routingMethodId" => (@enums["Routing_Method"][cfg[:method]] || 10),
                "routingTypeId"   => (@enums["Routing_Type"][cfg[:type]] || 3),
                "services"        => []
              }
            ]
            @load_balancers[idx]["virtualServers"] << virtual_server
          end
        end

        def join!
          @pending = []

          until @queue.empty?
            job = @queue.pop
            merge(job[:cfg], job[:idx])
          end

          # Perform the API calls for join.
          @load_balancers.each_with_index do |lb, idx|
            next unless @pending[idx]
            @logger.debug("Updating VIP #{lb['id']} with: #{lb['virtualServers']}")
            vip_id = @services["VirtualIpAddress"].object_with_id(lb["id"])
            sl_warden { vip_id.editObject("virtualServers" => lb["virtualServers"]) }  
          end
        end

        def merge(cfg, idx)
          # Get the service group. Create it if not found.
          sg = @load_balancers[idx]["virtualServers"].find(lambda { append_service_group(cfg, idx) }) { |g| g["port"] == cfg[:port] }
          # Get the IP address ID of the current machine.
          ip_id = ip_address_id(@env)
          unless sg["serviceGroups"].first["services"].index { |s| s["ipAddressId"] == ip_id }
            @logger.debug("Merging service: #{cfg[:service]}")
            # Add the service to the group.
            sg["serviceGroups"].first["services"] << {
              "enabled"         => 1,
              "ipAddressId"     => ip_id,
              "groupReferences" => [ { "weight" => cfg[:service].weight } ],
              "healthChecks"    => [ { "healthCheckTypeId" => (@enums["Health_Check_Type"][cfg[:service].health_check] || 21) } ],
              "port"            => cfg[:service].destination_port
            }
            # Mark the load balancer object as pending update
            @pending[idx] = true
          end
        end

        def prepare
          @env[:ui].info I18n.t("vagrant_softlayer.vm.joining_load_balancers")
          
          # For each definition, check if the load balancer exists and enqueue
          # the join operation.
          @queue = []
          @env[:machine].provider_config.load_balancers.each do |cfg|
            idx = @load_balancers.index { |lb| lb["ipAddress"]["ipAddress"] == cfg[:vip] }
            raise Errors::SLLoadBalancerNotFound unless idx
            @queue << { :cfg => cfg, :idx => idx }
          end
        end
      end
    end
  end
end
