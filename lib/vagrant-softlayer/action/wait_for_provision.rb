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

          env[:sl_machine] = env[:sl_client]["SoftLayer_Virtual_Guest"].object_with_id(env[:machine].id.to_i)
          
          virtual_server = ::SoftLayer::VirtualServer.server_with_id(env[:machine].id.to_i, :client => env[:sl_client])
          
          #Rechecks every 10 sec
          ready = virtual_server.wait_until_ready((env[:machine].provider_config.provision_timeout.to_f/10).ceil, env[:machine].provider_config.transaction_wait, 10) do |server_ready|
            unless server_ready
              provision_status = env[:sl_machine].getActiveTransaction
              provision_status = " Provision status: #{provision_status["transactionStatus"]["friendlyName"]} (#{provision_status["transactionStatus"]["name"]})." if provision_status && ! provision_status.empty?
              @logger.info("#{env[:machine].provider_config.hostname} is still provisioning. Retrying in 10 seconds.#{provision_status}")
            end
          end

          raise Errors::SLProvisionTimeoutError unless ready

          env[:ui].info I18n.t("vagrant_softlayer.vm.provisioned")

          @app.call(env)
        end
      end
    end
  end
end
