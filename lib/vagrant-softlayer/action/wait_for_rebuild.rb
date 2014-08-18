require "log4r"

module VagrantPlugins
  module SoftLayer
    module Action
      # Waits until the new machine has been rebuilt.
      class WaitForRebuild
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::wait_for_rebuild")
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.wait_for_rebuild")

          #Rechecks every 10 sec
          virtual_server = ::SoftLayer::VirtualServer.server_with_id(env[:machine].id.to_i, :client => env[:sl_client])
          
          ready = virtual_server.wait_until_ready((env[:machine].provider_config.rebuild_timeout.to_f/10).ceil, env[:machine].provider_config.transaction_wait, 10) do |server_ready|
            unless server_ready
              rebuild_status = env[:sl_machine].getActiveTransaction
              rebuild_status = " Rebuild status: #{rebuild_status["transactionStatus"]["friendlyName"]} (#{rebuild_status["transactionStatus"]["name"]})." if rebuild_status && ! rebuild_status.empty?
              @logger.info("#{env[:machine].provider_config.hostname} is still rebuilding. Retrying in 10 seconds.#{rebuild_status}")
            end
          end

          raise Errors::SLRebuildTimeoutError unless ready

          env[:ui].info I18n.t("vagrant_softlayer.vm.rebuilt")

          @app.call(env)
        end
      end
    end
  end
end
