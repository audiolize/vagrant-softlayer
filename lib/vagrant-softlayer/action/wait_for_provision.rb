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

          env[:sl_machine] = env[:sl_virtual_guest].object_with_id(env[:machine].id.to_i)

          retry_msg = lambda { @logger.debug("Object not found, retrying in 10 seconds.") }

          # Defaults to 20 minutes timeout
          Timeout::timeout(env[:machine].provider_config.provision_timeout, Errors::SLProvisionTimeoutError) do
            @logger.debug("Checking if the newly ordered machine has been provisioned.")
            sl_warden(retry_msg, 10) do
              while env[:sl_machine].getPowerState["name"] != "Running" || env[:sl_machine].object_mask( { "provisionDate" => "" } ).getObject == {}
                @logger.debug("The machine is still provisioning. Retrying in 10 seconds.")
                sleep 10
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
