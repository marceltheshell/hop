require 'test_helper'

  describe HopServer::Application, 'configuration' do
    let(:config) { described_class.config }

    it "filters sesitive parameters from logs" do
      sensitive_params = [:password, :dob, :phone, :token]
      sensitive_params.each do |param|
        assert_includes config.filter_parameters, param
      end
    end

    it "Only filters sesitive parameters from logs" do
      sensitive_params = [:first_name, :rfid, :last_name, :expires_at]
      sensitive_params.each do |param|
        refute config.filter_parameters.include?(param)
      end
    end

  end
