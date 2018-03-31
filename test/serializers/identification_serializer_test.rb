require 'test_helper'

class IdentificationSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }
  let(:identification) { identifications(:default) }

  it "#as_json" do
    IdentificationSerializer.new( identification ).as_json do |json|
      assert json.key?('id')
      assert json.key?('identification_type')
      assert json.key?('issuer')
      assert json.key?('expires_at')
      assert json.key?('image_id')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

  it "serializes identification missing field errors" do
    id = user.identification
    id.expires_at = nil

    refute user.valid?
    UserSerializer.new( user ).as_json  do |json|
      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert_match %r{can't be blank}i, json.dig('errors', 'identification', 'expires_at').join
    end
  end

end
