module VagrantPlugins
  module SoftLayer
    module Action
      # This suspends the running instance.
      class SuspendInstance
        include Util::Warden

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.suspending")
          sl_warden { env[:sl_machine].pause }
          
          @app.call(env)
        end
      end
    end
  end
end
