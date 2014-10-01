require "spec_helper"

describe VagrantPlugins::SoftLayer::Config do
  let(:config)  { described_class.new }
  let(:machine) { double("machine") }

  describe "defaults" do
    subject do
      config.tap do |o|
        o.finalize!
      end
    end

    its("api_key")      { should be_nil }
    its("endpoint_url") { should eq VagrantPlugins::SoftLayer::API_PUBLIC_ENDPOINT }
    its("username")     { should be_nil }

    its("datacenter")        { should be_nil }
    its("dedicated")         { should be_false }
    its("disk_capacity")     { should be_nil }
    its("domain")            { should be_nil }
    its("force_private_ip")  { should be_false }
    its("hostname")          { should be_nil }
    its("hourly_billing")    { should be_true }
    its("image_guid")        { should be_nil }
    its("local_disk")        { should be_true }
    its("max_memory")        { should eq 1024 }
    its("network_speed")     { should eq 10 }
    its("operating_system")  { should eq "UBUNTU_LATEST" }
    its("post_install")      { should be_nil }
    its("private_only")      { should be_false }
    its("provision_timeout") { should eq 1200 }
    its("rebuild_timeout")   { should eq 1200 }
    its("ssh_key")           { should be_nil }
    its("start_cpus")        { should eq 1 }
    its("transaction_wait")  { should be_true }
    its("user_data")         { should be_nil }
    its("vlan_private")      { should be_nil }
    its("vlan_public")       { should be_nil }

    its("load_balancers") { should eq [] }
    its("manage_dns")     { should be_false }
  end

  describe "overriding defaults" do
    context "booleans" do
      [true, false].each do |bool|
        [:dedicated, :force_private_ip, :hourly_billing, :local_disk, :manage_dns, :private_only, :transaction_wait].each do |attribute|
          it "should accept both true and false for #{attribute}" do
            config.send("#{attribute}=".to_sym, bool)
            config.finalize!
            expect(config.send(attribute)).to eq bool
          end
        end
      end
    end

    context "integers" do
      [:max_memory, :network_speed, :provision_timeout, :rebuild_timeout, :ssh_key, :start_cpus, :vlan_private, :vlan_public].each do |attribute|
        it "should not default #{attribute} if overridden" do
          config.send("#{attribute}=".to_sym, 999)
          config.finalize!
          expect(config.send(attribute)).to eq 999
        end
      end
    end

    context "strings" do
      [:api_key, :datacenter, :endpoint_url, :username, :domain, :hostname, :image_guid, :operating_system, :post_install, :ssh_key, :user_data, :vlan_private, :vlan_public].each do |attribute|
        it "should not default #{attribute} if overridden" do
          config.send("#{attribute}=".to_sym, "foo")
          config.finalize!
          expect(config.send(attribute)).to eq "foo"
        end
      end
    end

    context "int hash" do
      it "should not default disk_capacity if overriden" do
        config.send("disk_capacity=".to_sym, { 0 => 100, 2 => 25 } )
        config.finalize!
        expect(config.send("disk_capacity")).to eq { 0 => 100, 2 => 25 }
      end
    end
  end

  describe "joining load balancer" do
    it "should set weight to 1 by default" do
      config.join_load_balancer :port => 443, :vip => "1.1.1.1"
      config.finalize!
      expect(config.load_balancers.first[:service].weight).to eq(1)
    end

    it "should set passed options" do
      config.join_load_balancer :foo => "bar", :port => 443, :vip => "1.1.1.1"
      config.finalize!
      expect(config.load_balancers.first[:foo]).to eq("bar")
    end

    it "should set service parameters" do
      config.join_load_balancer :port => 443, :vip => "1.1.1.1" do |srv|
        srv.destination_port = 443
        srv.health_check     = "DNS"
        srv.notes            = "Some notes"
        srv.weight           = 9
      end
      config.finalize!
      expect(config.load_balancers.first[:service].destination_port).to eq(443)
      expect(config.load_balancers.first[:service].health_check).to eq("DNS")
      expect(config.load_balancers.first[:service].notes).to eq("Some notes")
      expect(config.load_balancers.first[:service].weight).to eq(9)
    end
  end

  describe "using SL_ environment variables" do
    before :each do
      ENV.stub(:[]).with("SL_API_KEY").and_return("env_api_key")
      ENV.stub(:[]).with("SL_USERNAME").and_return("env_username")
    end

    subject do
      config.tap do |o|
        o.finalize!
      end
    end

    its("api_key")  { should eq "env_api_key" }
    its("username") { should eq "env_username" }
  end

  describe "validation" do
    before :each do
      # Setup some good configuration values
      config.api_key  = "An API key"
      config.username = "An username"

      config.datacenter        = "ams01"
      config.dedicated         = false
      config.domain            = "example.com"
      config.disk_capacity     = { 0 => 25 }
      config.force_private_ip  = false
      config.hostname          = "vagrant"
      config.hourly_billing    = true
      config.image_guid        = nil
      config.local_disk        = true
      config.max_memory        = 1024
      config.network_speed     = 10
      config.operating_system  = "UBUNTU_LATEST"
      config.post_install      = "http://example.com/foo"
      config.provision_timeout = 1200
      config.rebuild_timeout   = 1200
      config.ssh_key           = ["First key", "Second key"]
      config.start_cpus        = 1
      config.transaction_wait  = true
      config.user_data         = "some metadata"
      config.vlan_private      = 111
      config.vlan_public       = 222

      config.manage_dns        = false

      machine.stub_chain(:config, :vm, :hostname).and_return(nil)
    end

    it "should validate" do
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(:no).item
    end

    it "should fail if API key is not given" do
      config.api_key = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if username is not given" do
      config.username = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if domain is not given" do
      config.domain = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if hostname is not given" do
      config.hostname = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should validate if hostname is not given but config.vm.hostname is set" do
      config.hostname = nil
      config.finalize!
      machine.stub_chain(:config, :vm, :hostname).and_return("vagrant")
      expect(config.validate(machine)["SoftLayer"]).to have(:no).item
    end

    it "should fail if ssh key is not given" do
      config.ssh_key = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if a load balancer is specified without vip" do
      config.join_load_balancer :port => 443 do |srv|
        srv.destination_port = 443
      end
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if a load balancer is specified without port" do
      config.join_load_balancer :vip => "1.1.1.1" do |srv|
        srv.destination_port = 443
      end
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if a load balancer is specified without destination port" do
      config.join_load_balancer :port => 443, :vip => "1.1.1.1"
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if two load balancers han been defined with same vip and port" do
      config.join_load_balancer :port => 443, :vip => "1.1.1.1" do |srv|
        srv.destination_port = 443
      end
      config.join_load_balancer :port => 443, :vip => "1.1.1.1" do |srv|
        srv.destination_port = 8443
      end
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should validate if a load balancer if specified with vip, port and destination port" do
      config.join_load_balancer :port => 443, :vip => "1.1.1.1" do |srv|
        srv.destination_port = 443
      end
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(:no).item
    end

    it "should fail if disk_capacity and image_guid are both specified" do
      config.disk_capacity = { 0 => 25 }
      config.image_guid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      config.operating_system = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should fail if operating system and image_guid are both specified" do
      config.image_guid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
      config.operating_system = "UBUNTU_LATEST"
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end

    it "should validate if operating_system and disk_capacity are both specified" do
      config.operating_system = "UBUNTU_LATEST"
      config.disk_capacity = { 0 => 25 }
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(:no).item
    end
  end
end
