module VagrantPlugins
  module SoftLayer
    module Action
      # This starts a stopped instance.
      class StartInstance
        include Util::Warden

        def initialize(app, env)
          @app    = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.starting")
          sl_warden { env[:sl_machine].powerOn }
          
          @app.call(env)
        end
      end
    end
  end
end
