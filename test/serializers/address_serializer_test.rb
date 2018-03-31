require 'test_helper'

class AddressSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }
  let(:address) { addresses(:two) }

  it "#as_json" do
    AddressSerializer.new( address ).as_json do |json|
      assert json.key?('address_type')
      assert json.key?('street1')
      assert json.key?('street2')
      assert json.key?('city')
      assert json.key?('state')
      assert json.key?('country')
      assert json.key?('postal')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

  it "serializes address errors" do

    user.addresses[0].country = nil
    
    refute user.valid?
    UserSerializer.new( user ).as_json  do |json|
      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert_match %r{can't be blank}i, json.dig('errors', 'default_address', 'country').join
    end
  end
end
