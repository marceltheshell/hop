require 'test_helper'

class UsersListSerializerTest < ActiveSupport::TestCase

  let(:users) { User.page(1).per(10) }
  let(:deleted_users) { User.deleted.page(1).per(10) }

  it "#as_json" do
    UsersListSerializer.new( users ).as_json do |json|
      assert json.key?('total')
      assert json.key?('pages')
      assert json.key?('users')
      json.dig('users').first.tap do |json|
        assert json.key?('id')
        assert json.key?('email')
        assert json.key?('dob')
        assert json.key?('first_name')
        assert json.key?('height_in_cm')
        assert json.key?('weight_in_kg')
        assert json.key?('phone')
        assert json.key?('image_id')
        assert json.key?('rfid')
        assert json.key?('balance_in_cents')
        assert json['deactivated_at'].nil?
        refute json.key?('user')
        refute json.key?('code')
        refute json.key?('message')
        refute json.key?('errors')
      end
    end
  end

  it "#UsersListSerializer appends user associations" do
    UsersListSerializer.new( users ).as_json do |json|
      assert json.key?('total')
      assert json.key?('pages')
      assert json.key?('users')
      json.dig('users').second.tap do |json|
        assert json.key?('addresses')
        assert json.key?('identification')
        assert json.key?('payment_method')
      end
    end
  end

  it "#as_json returned deleted users" do
    users.first.deactivate!
    users.second.deactivate!

    UsersListSerializer.new( deleted_users ).as_json do |json|
      refute json.key?('next_page')
      json = json.dig('users')
      assert json[0].key?('deactivated_at')
      refute json[0]['deactivated_at'].nil?
    end
  end

end
