module VagrantPlugins
  module SoftLayer
    module Action
      # This creates a new instance.
      class CreateInstance
        include Util::Network
        include Util::Warden

        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env

          @env[:ui].info I18n.t("vagrant_softlayer.vm.creating")

          sl_warden { env[:sl_product_order].verifyOrder(env[:sl_virtual_guest].generateOrderTemplate(order_template)) }

          result = sl_warden { env[:sl_virtual_guest].createObject(order_template) }
          @env[:machine].id = result["id"].to_s

          @app.call(@env)
        end

        def get_hostname
          @env[:machine].provider_config.hostname || @env[:machine].config.vm.hostname
        end

        def get_vlan_id(vlan_name, vlan_space)
          return vlan_name unless vlan_name.kind_of?(String)

          routers = @env[:sl_account].object_mask("mask[routers,routers.datacenter,routers.networkVlans,routers.networkVlans.networkSpace,routers.networkVlans.type]").getObject["routers"]

          routers.each do |router|
            next if @env[:machine].provider_config.datacenter && router["datacenter"]["name"] != @env[:machine].provider_config.datacenter
            router["networkVlans"].each do |vlan|
              vlan_qualified_name = [ router["hostname"].split('.').reverse.join('.'), vlan["vlanNumber"] ].join('.')
              return vlan["id"] if vlan.has_key?("name") && vlan["type"]["keyName"] == "STANDARD" && vlan["networkSpace"] == vlan_space.to_s.upcase && (vlan["name"] == vlan_name || vlan_qualified_name == vlan_name)
            end
          end

          raise Errors::SLVlanIdNotFound, :vlan_space => vlan_space.to_s, :vlan_name => vlan_name.inspect
        end

        def order_template
          template = {
            "dedicatedAccountHostOnlyFlag" => @env[:machine].provider_config.dedicated,
            "domain"                       => @env[:machine].provider_config.domain,
            "hostname"                     => get_hostname,
            "hourlyBillingFlag"            => @env[:machine].provider_config.hourly_billing,
            "localDiskFlag"                => @env[:machine].provider_config.local_disk,
            "maxMemory"                    => @env[:machine].provider_config.max_memory,
            "networkComponents"            => [ { :maxSpeed => @env[:machine].provider_config.network_speed } ],
            "privateNetworkOnlyFlag"       => @env[:machine].provider_config.private_only,
            "sshKeys"                      => ssh_keys(@env),
            "startCpus"                    => @env[:machine].provider_config.start_cpus
          }

          template["blockDevices"]                   =  @env[:machine].provider_config.disk_capacity.map{ |key,value| { "device"=> key.to_s, "diskImage" => { "capacity" => value.to_s } } } if @env[:machine].provider_config.disk_capacity
          template["blockDeviceTemplateGroup"]       = { :globalIdentifier => @env[:machine].provider_config.image_guid } if @env[:machine].provider_config.image_guid
          template["datacenter"]                     = { :name => @env[:machine].provider_config.datacenter } if @env[:machine].provider_config.datacenter
          template["operatingSystemReferenceCode"]   = @env[:machine].provider_config.operating_system if !@env[:machine].provider_config.image_guid
          template["postInstallScriptUri"]           = @env[:machine].provider_config.post_install if @env[:machine].provider_config.post_install
          template["primaryBackendNetworkComponent"] = { :networkVlan => { :id => get_vlan_id(@env[:machine].provider_config.vlan_private, :private) } } if @env[:machine].provider_config.vlan_private
          template["primaryNetworkComponent"]        = { :networkVlan => { :id => get_vlan_id(@env[:machine].provider_config.vlan_public,  :public) } } if @env[:machine].provider_config.vlan_public
          template["userData"]                       = [ { :value => @env[:machine].provider_config.user_data } ] if @env[:machine].provider_config.user_data

          return template
        end
      end
    end
  end
end
