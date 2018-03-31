require 'test_helper'

class BootSerializerTest < ActiveSupport::TestCase
  let(:user) { ServiceUser.create!(email: "test2service_user@test.com", password: "123456") }
  let(:token) { Knock::AuthToken.new(payload: { sub: user.id }) }

  it "#as_json" do
    BootSerializer.new( token ).as_json do |json|
      assert json.key?('jwt')
      assert json.key?('bridge_pay')
      assert json.key?('aws')
      assert json.key?('resources')
      assert json.key?('venues')

      json.dig('aws').tap do |aws|
        assert aws.key?('region')
        assert aws.key?('bucket')
        assert aws.key?('identity_id')
        assert aws.key?('identity_pool_id')
        assert aws.key?('uploads')
        assert aws.key?('lowres')
        assert aws.key?('hires')
      end
    end
  end
end
