module VagrantPlugins
  module SoftLayer
    module Action
      # This rebuilds the running instance.
      class RebuildInstance
        include Util::Network
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::rebuild_instance")
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_softlayer.vm.rebuilding")

          # Wipe out provision sentinel file, we need to run provisioning after rebuild
          @logger.debug("Looking for provision sentinel file.")
          provision_file = env[:machine].data_dir.join("action_provision")
          if provision_file.file?
            @logger.debug("Removing provision sentinel file.")
            provision_file.delete
          end

          template = { "sshKeyIds" => ssh_keys(env, true) }
          template["customProvisionScriptUri"] = env[:machine].provider_config.post_install if env[:machine].provider_config.post_install
          
          sl_warden { env[:sl_machine].reloadOperatingSystem("FORCE", template) }
          
          @app.call(env)
        end
      end
    end
  end
end
