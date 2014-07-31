require "log4r"

module VagrantPlugins
  module SoftLayer
    module Action
      # This action creates the SoftLayer service objects and
      # puts them into keys in the environment.
      # Also, if a machine id is found, another key called
      # `:sl_machine` and containing the masked object is created.
      class SetupSoftLayer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::connect_softlayer")
        end

        def call(env)
          @logger.info("Creating the SoftLayer service objects...")

          env[:sl_credentials] = {
            :api_key      => env[:machine].provider_config.api_key,
            :endpoint_url => env[:machine].provider_config.endpoint_url,
            :timeout      => env[:machine].provider_config.api_timeout,
            :user_agent   => "vagrant-softlayer",
            :username     => env[:machine].provider_config.username
          }

          env[:sl_client] = ::SoftLayer::Client.new(env[:sl_credentials])

          unless env[:machine].id.nil? || env[:machine].id.empty?
            env[:sl_machine] = env[:sl_client]["SoftLayer_Virtual_Guest"].object_with_id(env[:machine].id.to_i)
          end

          # Carry on
          @app.call(env)
        end
      end
    end
  end
end
