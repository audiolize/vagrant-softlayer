require "pathname"
require "vagrant-softlayer/util/network"
require "vagrant-softlayer/util/warden"

module VagrantPlugins
  module SoftLayer
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b.use Call, Is, :not_created do |env2, b3|
                if env2[:result]
                  b3.use Message, :error, "vagrant_softlayer.vm.not_created"
                  next
                end
              end
              b2.use SetupSoftLayer
              b2.use DestroyInstance
              b2.use UpdateDNS
            else
              b2.use Message, :warn, "vagrant_softlayer.vm.not_destroying"
            end
          end
        end
      end

      # This action is called to halt the remote machine.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, Is, :running do |env, b2|
            if !env[:result]
              b2.use Message, :error, "vagrant_softlayer.vm.not_running"
              next
            end

            b2.use SetupSoftLayer
            b2.use StopInstance
          end
        end
      end

      # This action is called to run provisioners on the machine.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, Is, :running do |env, b2|
            if !env[:result]
              b2.use Message, :error, "vagrant_softlayer.vm.not_running"
              next
            end

            b2.use Provision
            b2.use SyncFolders
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use SetupSoftLayer
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use SetupSoftLayer
          b.use ReadState
        end
      end

      # This action is called to rebuild the machine OS from scratch.
      def self.action_rebuild
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, Confirm, I18n.t("vagrant_softlayer.vm.rebuild_confirmation"), :force_rebuild do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b.use Call, Is, :not_created do |env2, b3|
                if env2[:result]
                  b3.use Message, :error, "vagrant_softlayer.vm.not_created"
                  next
                end
              end
              b2.use SetupSoftLayer
              b2.use RebuildInstance
              b2.use Provision
              b2.use SyncFolders
              b2.use WaitForRebuild
              b2.use WaitForCommunicator
            else
              b2.use Message, :warn, "vagrant_softlayer.vm.not_rebuilding"
            end
          end
        end
      end

      # This action is called to reload the machine.
      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use action_halt
          b.use action_up
        end
      end

      # This action is called to SSH into the machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, Is, :running do |env, b2|
            if !env[:result]
              b2.use Message, :error, "vagrant_softlayer.vm.not_running"
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, Is, :running do |env, b2|
            if !env[:result]
              b2.use Message, :error, "vagrant_softlayer.vm.not_running"
              next
            end

            b2.use SSHRun
          end
        end
      end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBoxUrl
          b.use ConfigValidate
          b.use SetupSoftLayer
          b.use Call, Is, :not_created do |env1, b1|
            if env1[:result]
              b1.use SetupSoftLayer
              b1.use Provision
              b1.use SyncFolders
              b1.use UpdateDNS
              b1.use CreateInstance
              b1.use WaitForProvision
              b1.use WaitForCommunicator
            else
              b1.use Call, Is, :halted do |env2, b2|
                if env2[:result]
                  b2.use SetupSoftLayer
                  b2.use Provision
                  b2.use SyncFolders
                  b2.use StartInstance
                  b2.use WaitForCommunicator
                else
                  b2.use Message, :warn, "vagrant_softlayer.vm.already_running"
                end
              end
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))

      autoload :CreateInstance,   action_root.join("create_instance")
      autoload :DestroyInstance,  action_root.join("destroy_instance")
      autoload :Is,               action_root.join("is")
      autoload :Message,          action_root.join("message")
      autoload :ReadSSHInfo,      action_root.join("read_ssh_info")
      autoload :ReadState,        action_root.join("read_state")
      autoload :RebuildInstance,  action_root.join("rebuild_instance")
      autoload :SetupSoftLayer,   action_root.join("setup_softlayer")
      autoload :StartInstance,    action_root.join("start_instance")
      autoload :StopInstance,     action_root.join("stop_instance")
      autoload :SyncFolders,      action_root.join("sync_folders")
      autoload :UpdateDNS,        action_root.join("update_dns")
      autoload :WaitForProvision, action_root.join("wait_for_provision")
      autoload :WaitForRebuild,   action_root.join("wait_for_rebuild")
    end
  end
end
