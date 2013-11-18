require 'optparse'

module VagrantPlugins
  module SoftLayer
    module Command
      class Rebuild < Vagrant.plugin('2', :command)
        def execute
          options = {}
          options[:force] = false

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant rebuild [vm-name]"
            o.separator ""

            o.on("-f", "--force", "Rebuild without confirmation.") do |f|
              options[:force] = f
            end
          end

          argv = parse_options(opts)
          return if !argv

          declined = false
          with_target_vms(argv) do |vm|
            action_env = vm.action(:rebuild, :force_rebuild => options[:force], :provision_ignore_sentinel => false)
            declined = true if action_env.has_key?(:force_rebuild_result) && action_env[:force_rebuild_result] == false
          end

          declined ? 1 : 0
        end
      end
    end
  end
end
