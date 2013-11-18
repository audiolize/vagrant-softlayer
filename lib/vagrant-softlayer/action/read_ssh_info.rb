module VagrantPlugins
  module SoftLayer
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        include Util::Network
        include Util::Warden

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env)

          @app.call(env)
        end

        def read_ssh_info(env)
          return nil unless env[:sl_machine]

          return { :host => ip_address(env), :port => 22 }
        end
      end
    end
  end
end
