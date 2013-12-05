module VagrantPlugins
  module SoftLayer
    module Action
      # Cleanup orphaned virtual servers from load balancers.
      class LoadBalancerCleanup
        include Util::LoadBalancer
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::load_balancer_cleanup")
        end

        def call(env)
          @env = env

          if enabled?
            setup
            cleanup!
            rebalance!
          end

          @app.call(@env)
        end

        def cleanup!
          @env[:ui].info I18n.t("vagrant_softlayer.vm.load_balancer_cleanup")

          # Keep it safe here. We delete a virtual server only if
          # no services exist on any service group. In the future,
          # we will find a way to selectively delete empty service groups.
          @load_balancers.each do |load_balancer|
            load_balancer["virtualServers"].each do |vs|
              if vs["serviceGroups"].inject(0) { |sum, sg| sum + sg["services"].count } == 0
                @logger.debug("Found empty virtual server (ID #{vs['id']}). Deleting.")
                sl_warden { @services["VirtualServer"].object_with_id(vs["id"]).deleteObject }
              end
            end
          end
        end
      end
    end
  end
end
