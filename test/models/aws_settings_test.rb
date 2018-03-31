require 'test_helper'

class AwsSettingsTest < ActiveSupport::TestCase
  let(:aws) { AwsSettings.instance }

  it "works with block" do
    AwsSettings.instance do |aws|
      refute aws.nil?
      refute aws.secret.nil?
    end
  end

  it "has id" do
    refute aws.id.nil?
  end

  it "has secret" do
    refute aws.secret.nil?
  end

  it "has region" do
    refute aws.region.nil?
  end

  it "has bucket" do
    refute aws.bucket.nil?
  end

  it "has identity_id" do
    refute aws.identity_id.nil?
  end

  it "has identity_pool_id" do
    refute aws.identity_pool_id.nil?
  end
end
