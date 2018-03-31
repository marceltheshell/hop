require 'test_helper'

class AuthSerializerTest < ActiveSupport::TestCase
  let(:user) { ServiceUser.create!(email: "test1service_user@test.com", password: "123456") }
  let(:token) { Knock::AuthToken.new(payload: { sub: user.id }) }

  it "#as_json" do
    AuthSerializer.new( token, user ).as_json do |json|
      assert json.key?('jwt')
      assert json.key?('user')
      assert_equal 'ServiceUser', json['user']['type']
      json.dig('user').tap do |user|
        assert user.key?('email')
      end
    end
  end

  it "#as_json with errors" do
    user.email = nil
    refute user.valid?

    AuthSerializer.new( token, user ).as_json do |json|
      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert json.dig('errors').is_a?(Hash)
    end
  end
end
