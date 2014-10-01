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

          virtual_guest_object_mask = [
                                       "activeTransaction.id",
                                       "activeTransaction.transactionStatus.friendlyName",
                                       "activeTransaction.transactionStatus.name",
                                       "lastOperatingSystemReload.id",
                                       "provisionDate",
                                      ]

          # Defaults to 20 minutes timeout
          Timeout::timeout(env[:machine].provider_config.rebuild_timeout, Errors::SLRebuildTimeoutError) do
            @logger.debug("Checking if the instance has been rebuilt.")
            sl_warden do
              ready = false

              while ! ready
                softlayer_properties   = env[:sl_machine].object_mask("mask[#{virtual_guest_object_mask.join(",")}]").getObject

                has_os_reload          = softlayer_properties.has_key?("lastOperatingSystemReload")
                has_active_transaction = softlayer_properties.has_key?("activeTransaction")
                provisioned            = softlayer_properties.has_key?("provisionDate")
                reloading_os           = has_active_transaction && has_os_reload && (softlayer_properties["lastOperatingSystemReload"]['id'] == softlayer_properties["activeTransaction"]['id'])

                ready                  = provisioned && !reloading_os && (!env[:machine].provider_config.transaction_wait || !has_active_transaction)

                if ! ready
                  rebuild_status = env[:sl_machine].getActiveTransaction
                  rebuild_status = " Rebuild status: #{rebuild_status["transactionStatus"]["friendlyName"]} (#{rebuild_status["transactionStatus"]["name"]})." if rebuild_status && ! rebuild_status.empty?
                  @logger.debug("#{env[:machine].provider_config.hostname} is still rebuilding. Retrying in 10 seconds.#{rebuild_status}")
                  sleep 10
                end
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
