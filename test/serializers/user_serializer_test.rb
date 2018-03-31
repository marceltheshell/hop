require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

  it "#as_json" do
    UserSerializer.new( user ).as_json do |json|
      assert json.key?('user')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')

      json.dig('user').tap do |json|
        assert json.key?('id')
        assert json.key?('email')
        assert json.key?('dob')
        assert json.key?('first_name')
        assert json.key?('height_in_cm')
        assert json.key?('weight_in_kg')
        assert json.key?('phone')
        assert json.key?('image_id')
        assert json.key?('rfid')
        assert json.key?('qr_code_path')
        assert json.key?('balance_in_cents')
      end
    end
  end

  it "#as_json with errors" do
    user.email = nil
    user.phone = nil
    user.save
    refute user.valid?

    UserSerializer.new( user ).as_json do |json|
      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert json.dig('errors').is_a?(Hash)
    end
  end

  it "#as_json with address, identification, and payment_method" do
    UserSerializer.new( user ).as_json  do |json|
      assert json.key?('user')
      assert json.dig('user').key?('addresses')
      assert json.dig('user').key?('identification')
      assert json.dig('user').key?('payment_method')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

end
