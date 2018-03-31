require 'test_helper'

class StatusSerializerTest < ActiveSupport::TestCase

  it "accepted" do
    StatusSerializer.new(:accepted).to_json do |json|
      json = JSON.parse(json).dig('data')
      assert json.key?('status')
      assert_match %r{accepted}, json.dig('status')
    end
  end

  it "deleted" do
    StatusSerializer.new(:deleted).to_json do |json|
      json = JSON.parse(json).dig('data')
      assert json.key?('status')
      assert_match %r{deleted}, json.dig('status')
    end
  end

end
