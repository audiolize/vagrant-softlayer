require "log4r"

module VagrantPlugins
  module SoftLayer
    module Action
      # Waits until the new machine has been provisioned.
      class WaitForProvision
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::wait_for_provision")
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.wait_for_provision")

          virtual_guest_object_mask = [
                                       "activeTransaction.id",
                                       "activeTransaction.transactionStatus.friendlyName",
                                       "activeTransaction.transactionStatus.name",
                                       "lastOperatingSystemReload.id",
                                       "provisionDate"
                                      ]

          env[:sl_machine] = env[:sl_virtual_guest].object_with_id(env[:machine].id.to_i)

          retry_msg = lambda { @logger.debug("Object not found, retrying in 10 seconds.") }

          # Defaults to 20 minutes timeout
          Timeout::timeout(env[:machine].provider_config.provision_timeout, Errors::SLProvisionTimeoutError) do
            @logger.debug("Checking if the newly ordered machine has been provisioned.")
            sl_warden(retry_msg, 10) do
              ready = false

              while ! ready
                softlayer_properties   = env[:sl_machine].object_mask("mask[#{virtual_guest_object_mask.join(",")}]").getObject

                has_os_reload          = softlayer_properties.has_key?("lastOperatingSystemReload")
                has_active_transaction = softlayer_properties.has_key?("activeTransaction")
                provisioned            = softlayer_properties.has_key?("provisionDate")
                reloading_os           = has_active_transaction && has_os_reload && (softlayer_properties["lastOperatingSystemReload"]['id'] == softlayer_properties["activeTransaction"]['id'])

                ready                  = provisioned && !reloading_os && (!env[:machine].provider_config.transaction_wait || !has_active_transaction)

                if ! ready
                  provision_status = env[:sl_machine].getActiveTransaction
                  provision_status = " Provision status: #{provision_status["transactionStatus"]["friendlyName"]} (#{provision_status["transactionStatus"]["name"]})." if provision_status && ! provision_status.empty?
                  @logger.debug("#{env[:machine].provider_config.hostname} is still provisioning. Retrying in 10 seconds.#{provision_status}")
                  sleep 10
                end
              end
            end
          end

          env[:ui].info I18n.t("vagrant_softlayer.vm.provisioned")

          @app.call(env)
        end
      end
    end
  end
end
