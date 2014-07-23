require "ostruct"

module VagrantPlugins
  module SoftLayer
    class Config < Vagrant.plugin("2", :config)
      # The API key to access SoftLayer.
      attr_accessor :api_key

      # The endpoint SoftLayer API url.
      attr_accessor :endpoint_url

      # The username to access SoftLayer.
      attr_accessor :username

      # The datacenter shortname.
      attr_accessor :datacenter

      # Whether to allocate a dedicated instance.
      attr_accessor :dedicated

      # The disk image capacity
      attr_accessor :disk_capacity

      # The domain of the instance.
      attr_accessor :domain

      # The hostname of the instance.
      attr_accessor :hostname

      # The billing type of the instance (true for hourly, false for monthly).
      attr_accessor :hourly_billing

      # The global identifier of the compute or flex image to use.
      attr_accessor :image_guid

      # The disk type of the instance (true for local, false for SAN).
      attr_accessor :local_disk

      # The amount of RAM of the instance.
      attr_accessor :max_memory

      # Network port speed in Mbps.
      attr_accessor :network_speed

      # The instance operating system identifier.
      attr_accessor :operating_system

      # URI of post-install script to download.
      attr_accessor :post_install

      # Whether or not the instance only has access to the private network.
      attr_accessor :private_only

      # The id or name of the ssh key to be provisioned.
      attr_accessor :ssh_key

      # The number of processors of the instance.
      attr_accessor :start_cpus

      # User defined metadata string.
      attr_accessor :user_data

      # The ID, name or qualified name of the private VLAN.
      attr_accessor :vlan_private

      # The ID, name or qualified name of the public VLAN.
      attr_accessor :vlan_public

      # The load balancers service groups to join.
      attr_reader :load_balancers

      # Automatically update DNS on create and destroy.
      attr_accessor :manage_dns

      def initialize
        @api_key      = UNSET_VALUE
        @endpoint_url = UNSET_VALUE
        @username     = UNSET_VALUE

        @datacenter       = UNSET_VALUE
        @dedicated        = UNSET_VALUE
        @disk_capacity    = UNSET_VALUE
        @domain           = UNSET_VALUE
        @hostname         = UNSET_VALUE
        @image_guid       = UNSET_VALUE
        @hourly_billing   = UNSET_VALUE
        @local_disk       = UNSET_VALUE
        @max_memory       = UNSET_VALUE
        @network_speed    = UNSET_VALUE
        @operating_system = UNSET_VALUE
        @post_install     = UNSET_VALUE
        @private_only     = UNSET_VALUE
        @ssh_key          = UNSET_VALUE
        @start_cpus       = UNSET_VALUE
        @user_data        = UNSET_VALUE
        @vlan_private     = UNSET_VALUE
        @vlan_public      = UNSET_VALUE

        @load_balancers = []
        @manage_dns     = UNSET_VALUE
      end

      # Set the load balancer service group to join.
      #
      # Available options:
      #
      # :method => Routing method. Default to round robin.
      # :port   => Load balancer virtual port.
      # :type   => Routing type. Default to TCP.
      # :vip    => Load balancer virtual IP address.
      #
      # An optional block will accept parameters for the
      # balanced service. Available parameters:
      #
      # :destination_port => TCP port on the node.
      # :health_check     => Service health check. Default to ping.
      # :weight           => Service weight. Default to 1.
      #
      def join_load_balancer(opts = {}, &block)
        # Defaults
        opts[:method] ||= "ROUND ROBIN"
        opts[:type]   ||= "TCP"
        opts[:service]  = OpenStruct.new(:destination_port => nil, :health_check => "PING", :weight => 1)

        yield opts[:service] if block_given?

        # Convert all options that belongs to
        # an enumeration in uppercase.
        opts[:method].upcase!
        opts[:type].upcase!
        opts[:service].health_check.upcase!

        @load_balancers << opts
      end

      def finalize!
        # Try to get username and api key from environment variables.
        # They will default to nil if the environment variables are not present.
        @api_key  = ENV["SL_API_KEY"] if @api_key == UNSET_VALUE
        @username = ENV["SL_USERNAME"] if @username == UNSET_VALUE

        # Endpoint url defaults to public SoftLayer API url.
        @endpoint_url = API_PUBLIC_ENDPOINT if @endpoint_url == UNSET_VALUE

        # No default datacenter.
        @datacenter = nil if @datacenter == UNSET_VALUE

        # Shared instance by default.
        @dedicated = false if @dedicated == UNSET_VALUE

        # 25GB disk capacity image by default.
        @disk_capacity = nil if @disk_capacity == UNSET_VALUE

        # Domain should be specified in Vagrantfile, so we set default to nil.
        @domain = nil if @domain == UNSET_VALUE

        # Hostname should be specified in Vagrantfile, either using `config.vm.hostname`
        # or the provider specific configuration entry.
        @hostname = nil if @hostname == UNSET_VALUE

        # Bill hourly by default.
        @hourly_billing = true if @hourly_billing == UNSET_VALUE

        # Disable the use of a specific block device image so we can leave the OS template as default
        @image_guid = nil if @image_guid == UNSET_VALUE

        # Use local disk by default.
        @local_disk = true if @local_disk == UNSET_VALUE

        # 1Gb of RAM by default.
        @max_memory = 1024 if @max_memory == UNSET_VALUE

        # 10Mbps by default.
        @network_speed = 10 if @network_speed == UNSET_VALUE

        # Provision with the latest Ubuntu by default.
        @operating_system = "UBUNTU_LATEST" if @operating_system == UNSET_VALUE

        # No post install script by default.
        @post_install = nil if @post_install == UNSET_VALUE

        # Private-network only is false by default.
        @private_only = false if @private_only == UNSET_VALUE

        # SSH key should be specified in Vagrantfile, so we set default to nil.
        @ssh_key = nil if @ssh_key == UNSET_VALUE

        # One processor by default.
        @start_cpus = 1 if @start_cpus == UNSET_VALUE

        # No user metadata by default.
        @user_data = nil if @user_data == UNSET_VALUE

        # No specific private VLAN by default.
        @vlan_private = nil if @vlan_private == UNSET_VALUE

        # No specific public VLAN by default.
        @vlan_public = nil if @vlan_public == UNSET_VALUE

        # DNS management off by default
        @manage_dns = false if @manage_dns == UNSET_VALUE
      end

      # Aliases for ssh_key for beautiful semantic.
      def ssh_keys=(value)
        @ssh_key = value
      end

      alias_method :ssh_key_id=, :ssh_keys=
      alias_method :ssh_key_ids=, :ssh_keys=
      alias_method :ssh_key_name=, :ssh_keys=
      alias_method :ssh_key_names=, :ssh_keys=

      def validate(machine)
        errors = []

        errors << I18n.t("vagrant_softlayer.config.api_key_required") if !@api_key
        errors << I18n.t("vagrant_softlayer.config.username_required") if !@username

        errors << I18n.t("vagrant_softlayer.config.domain_required") if !@domain
        errors << I18n.t("vagrant_softlayer.config.ssh_key_required") if !@ssh_key

        errors << I18n.t("vagrant_softlayer.config.img_guid_os_code_mutually_exclusive") if @image_guid && @operating_system
        errors << I18n.t("vagrant_softlayer.config.img_guid_capacity_mutually_exclusive") if @image_guid && @disk_capacity

        #  Fail if both `vm.hostname` and `provider.hostname` are nil.
        if !@hostname && !machine.config.vm.hostname
          errors << I18n.t("vagrant_softlayer.config.hostname_required")
        end

        # Fail if a load balancer has been specified without vip, port or destination port.
        unless @load_balancers.empty?
          @load_balancers.each do |lb|
            errors << I18n.t("vagrant_softlayer.config.lb_port_vip_required") unless (lb[:vip] && lb[:port] && lb[:service].destination_port)
          end
        end

        # Fail if two or more load balancers has been specified with same vip and port.
        if @load_balancers.map { |lb| { :port => lb[:port], :vip => lb[:vip] } }.uniq!
          errors << I18n.t("vagrant_softlayer.config.lb_duplicate")
        end

        { "SoftLayer" => errors }
      end
    end
  end
end
