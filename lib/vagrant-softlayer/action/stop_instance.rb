module VagrantPlugins
  module SoftLayer
    module Action
      # This stops the running instance.
      class StopInstance
        include Util::Warden

        def initialize(app, env)
          @app    = app
        end

        def call(env)
          if env[:machine].state.id == :halted
            env[:ui].info I18n.t("vagrant_softlayer.vm.already_stopped")
          else
            if env[:force_halt]
              env[:ui].info I18n.t("vagrant_softlayer.vm.stopping_force")
              sl_warden { env[:sl_machine].powerOff }
            else
              env[:ui].info I18n.t("vagrant_softlayer.vm.stopping")
              sl_warden { env[:sl_machine].powerOffSoft }
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
