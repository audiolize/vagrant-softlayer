module VagrantPlugins
  module SoftLayer
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is in the given status.
      class Is
        def initialize(app, env, status)
          @app    = app
          @status = status
        end

        def call(env)
          env[:result] = env[:machine].state.id == @status

          # Carry on, just in case
          @app.call(env)
        end
      end
    end
  end
end
