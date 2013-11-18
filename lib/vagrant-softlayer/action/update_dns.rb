module VagrantPlugins
  module SoftLayer
    module Action
      # Look for the DNS zone relative to the configured domain and,
      # on return path, perform an API call to add or remove the A
      # resource record for the host.
      class UpdateDNS
        include Util::Network
        include Util::Warden

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_softlayer::action::update_dns")
        end

        def call(env)
          @env = env

          @env[:dns_zone] = setup_dns

          @app.call(@env)

          update_dns
        end

        def dns_id
          id = nil
          id_file = @env[:machine].data_dir.join("dns_id")
          id = id_file.read.chomp.to_i if id_file.file?
          return id
        end

        def dns_id=(value)
          @logger.info("New machine DNS ID: #{value.inspect}")

          # The file that will store the id if we have one. This allows the
          # ID to persist across Vagrant runs.
          id_file = @env[:machine].data_dir.join("dns_id")

          if value
            # Write the "id" file with the id given.
            id_file.open("w+") do |f|
              f.write(value)
            end
          end
        end

        def setup_dns
          unless @env[:machine].provider_config.manage_dns
            @logger.debug("Not managing DNS. Going ahead.")
            return
          end

          dns_zone = ::SoftLayer::Service.new("SoftLayer_Dns_Domain", @env[:sl_credentials])

          domain = @env[:machine].provider_config.domain
          @logger.debug("Looking for #{domain} zone into the SoftLayer zone list.")
          dns_zone_obj = sl_warden { dns_zone.getByDomainName(domain).first }
          raise Errors::SLDNSZoneNotFound, :zone => domain unless dns_zone_obj
          @logger.debug("Found DNS zone: #{dns_zone_obj.inspect}")
          return dns_zone_obj
        end

        def update_dns
          unless @env[:machine].provider_config.manage_dns
            @logger.debug("Not managing DNS. Going ahead.")
            return
          end

          dns_resource = ::SoftLayer::Service.new("SoftLayer_Dns_Domain_ResourceRecord", @env[:sl_credentials])

          case @env[:action_name]
          when :machine_action_up
            hostname          = @env[:machine].provider_config.hostname || @env[:machine].config.vm.hostname
            @env[:sl_machine] = @env[:sl_connection].object_with_id(@env[:machine].id.to_i)
            res_template      = {
              "data"     => ip_address(@env),
              "domainId" => @env[:dns_zone]["id"],
              "host"     => hostname,
              "ttl"      => 86400,
              "type"     => "a"
            }
            @env[:ui].info I18n.t("vagrant_softlayer.vm.creating_dns_record")
            @logger.debug("Creating DNS A record for #{hostname}.#{@env[:dns_zone][:name]} (IP address #{res_template['data']}).")
            new_rr = sl_warden { dns_resource.createObject(res_template) }
            self.dns_id = new_rr["id"]
          when :machine_action_destroy
            @env[:ui].info I18n.t("vagrant_softlayer.vm.deleting_dns_record")
            @logger.debug("Deleting stored DNS A record (ID #{self.dns_id}).")
            sl_warden { dns_resource.object_with_id(self.dns_id).deleteObject }
          end
        end
      end
    end
  end
end
