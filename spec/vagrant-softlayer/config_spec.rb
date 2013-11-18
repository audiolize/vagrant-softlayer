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

    its("datacenter")       { should be_nil }
    its("dedicated")        { should be_false }
    its("domain")           { should be_nil }
    its("hostname")         { should be_nil }
    its("hourly_billing")   { should be_true }
    its("local_disk")       { should be_true }
    its("max_memory")       { should eq 1024 }
    its("network_speed")    { should eq 10 }
    its("operating_system") { should eq "UBUNTU_LATEST" }
    its("post_install")     { should be_nil }
    its("private_only")     { should be_false }
    its("ssh_key")          { should be_nil }
    its("start_cpus")       { should eq 1 }
    its("user_data")        { should be_nil }
    its("vlan_private")     { should be_nil }
    its("vlan_public")      { should be_nil }

    its("manage_dns") { should be_false }
  end

  describe "overriding defaults" do
    context "booleans" do
      [true, false].each do |bool|
        [:dedicated, :hourly_billing, :local_disk, :manage_dns, :private_only].each do |attribute|
          it "should accept both true and false for #{attribute}" do
            config.send("#{attribute}=".to_sym, bool)
            config.finalize!
            expect(config.send(attribute)).to eq bool
          end
        end
      end
    end

    context "integers" do
      [:max_memory, :network_speed, :ssh_key, :start_cpus, :vlan_private, :vlan_public].each do |attribute|
        it "should not default #{attribute} if overridden" do
          config.send("#{attribute}=".to_sym, 999)
          config.finalize!
          expect(config.send(attribute)).to eq 999
        end
      end
    end

    context "strings" do
      [:api_key, :datacenter, :endpoint_url, :username, :domain, :hostname, :operating_system, :post_install, :ssh_key, :user_data].each do |attribute|
        it "should not default #{attribute} if overridden" do
          config.send("#{attribute}=".to_sym, "foo")
          config.finalize!
          expect(config.send(attribute)).to eq "foo"
        end
      end
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

      config.datacenter       = "ams01"
      config.dedicated        = false
      config.domain           = "example.com"
      config.hostname         = "vagrant"
      config.hourly_billing   = true
      config.local_disk       = true
      config.max_memory       = 1024
      config.network_speed    = 10
      config.operating_system = "UBUNTU_LATEST"
      config.post_install     = "http://example.com/foo"
      config.ssh_key          = ["First key", "Second key"]
      config.start_cpus       = 1
      config.user_data        = "some metadata"
      config.vlan_private     = 111
      config.vlan_public      = 222

      config.manage_dns       = false

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
      machine.stub_chain(:config, :vm, :hostname).and_return("vagrant")
      expect(config.validate(machine)["SoftLayer"]).to have(:no).item
    end

    it "should fail if ssh key is not given" do
      config.ssh_key = nil
      config.finalize!
      expect(config.validate(machine)["SoftLayer"]).to have(1).item
    end
  end
end
