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

          update_dns

          @app.call(@env)
        end

        def add_record
          template = {
            "data"     => ip_address(@env),
            "domainId" => @dns_zone["id"],
            "host"     => hostname(@env),
            "ttl"      => 86400,
            "type"     => "a"
          }
          @env[:ui].info I18n.t("vagrant_softlayer.vm.creating_dns_record")
          @logger.debug("Creating DNS A record for #{template['host']}.#{@dns_zone[:name]} (IP address #{template['data']}).")
          resource = sl_warden { @resource.createObject(template) }
          self.dns_id = resource["id"]
        end

        def delete_record
          @env[:ui].info I18n.t("vagrant_softlayer.vm.deleting_dns_record")
          @logger.debug("Deleting stored DNS A record (ID #{self.dns_id}).")
          warn_msg = lambda { @env[:ui].warn I18n.t("vagrant_softlayer.errors.dns_record_not_found") }
          sl_warden(warn_msg) { @resource.object_with_id(self.dns_id).deleteObject }
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

        def update_dns
          unless @env[:machine].provider_config.manage_dns
            @logger.debug("Not managing DNS. Going ahead.")
            return
          end

          # Lookup the DNS zone
          zone   = @env[:sl_client]["SoftLayer_Dns_Domain"]
          domain = @env[:machine].provider_config.domain

          @logger.debug("Looking for #{domain} zone into the SoftLayer zone list.")
          @dns_zone = sl_warden { zone.getByDomainName(domain).first }
          raise Errors::SLDNSZoneNotFound, :zone => domain unless @dns_zone
          @logger.debug("Found DNS zone: #{@dns_zone.inspect}")

          # Add or remove the resource record
          @resource = @env[:sl_client]["SoftLayer_Dns_Domain_ResourceRecord"]
          case @env[:machine_action]
          when :up
            add_record unless self.dns_id
          when :destroy
            delete_record
          end
        end
      end
    end
  end
end
