require "log4r"

module VagrantPlugins
  module SoftLayer
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env)

          # Carry on
          @app.call(env)
        end

        def read_state(env)
          return :not_created unless env[:sl_machine]

          wipe_id = lambda do
            @logger.info("Machine not found, assuming it got destroyed.")
            env[:machine].id = nil
            next :not_created
          end

          state = sl_warden(wipe_id) { env[:sl_machine].getPowerState }
          if state && ["Halted", "Paused", "Running"].include?(state["name"])
            return state["name"].downcase.to_sym
          else
            return :unknown
          end
        end
      end
    end
  end
end
