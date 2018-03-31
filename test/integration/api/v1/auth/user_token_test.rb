require 'test_helper'

class Api::V1::AuthTest < ActionDispatch::IntegrationTest
  let(:secured_route) { api_secured_path }
  let(:login) { Hash(auth: Hash(email: "test@test.com", password: "123456")) }


  it 'gets token' do
    post api_v1_auth_path, params: login
    assert_response :success

    parsed_response.dig('data').tap do |json|
      assert json.dig('jwt').present?
      assert json.dig('user').present?
    end
  end

  it 'is authorized with valid token' do
    get secured_route, headers: authenticated_header
    assert_response :success
  end

  it 'is unauthorized without valid token' do
    get secured_route
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end
end
