module VagrantPlugins
  module SoftLayer
    module Action
      # This action sends a message to the UI,
      # with given level and text.
      class Message
        def initialize(app, env, level, message)
          @app     = app
          @level   = level
          @message = message
        end

        def call(env)
          env[:ui].send(@level, I18n.t(@message))

          # Carry on
          @app.call(env)
        end
      end
    end
  end
end
