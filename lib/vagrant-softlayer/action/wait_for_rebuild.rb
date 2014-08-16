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

          # Defaults to 20 minutes timeout
          Timeout::timeout(env[:machine].provider_config.rebuild_timeout, Errors::SLRebuildTimeoutError) do
            @logger.debug("Checking if the instance has been rebuilt.")
            sl_warden do
              while env[:sl_machine].object_mask("activeTransactionCount").getObject["activeTransactionCount"] > 0
                @logger.debug("The machine is still being rebuilt. Retrying in 10 seconds.")
                sleep 10
              end
            end
          end

          env[:ui].info I18n.t("vagrant_softlayer.vm.rebuilt")

          @app.call(env)
        end
      end
    end
  end
end
