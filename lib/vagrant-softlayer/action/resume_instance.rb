module VagrantPlugins
  module SoftLayer
    module Action
      # This resumes the suspended instance.
      class ResumeInstance
        include Util::Warden

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.resuming")
          sl_warden { env[:sl_machine].resume }
          
          @app.call(env)
        end
      end
    end
  end
end
