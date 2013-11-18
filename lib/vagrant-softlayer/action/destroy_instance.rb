module VagrantPlugins
  module SoftLayer
    module Action
      # This deletes the running instance.
      class DestroyInstance
        include Util::Warden

        def initialize(app, env)
          @app = app
        end

        def call(env)
          @app.call(env)

          env[:ui].info I18n.t("vagrant_softlayer.vm.destroying")
          
          sl_warden { env[:sl_machine].deleteObject }
          env[:machine].id = nil
        end
      end
    end
  end
end
