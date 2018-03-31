require 'test_helper'

class Api::V1::UsersGetTest < ActionDispatch::IntegrationTest
  let(:bad_auth_header) {Hash('Authorization': "Bearer 123dask")}

  it 'users#index' do
    get api_v1_users_path, headers: authenticated_header
    assert_response :success
    assert parsed_response.key?('data')

    parsed_response do |json|
      assert json.dig('data').key?('users')
      assert_equal Array, json.dig('data', 'users').class
    end
  end

  it 'users#show' do
    user = User.first

    get api_v1_user_path(user.id), headers: authenticated_header
    assert_response :success
    assert parsed_response.key?('data')
    assert parsed_response.dig('data')

    parsed_response.dig('data') do |json|
      assert json.key?('id')
      assert json.key?('email')
      assert json.key?('dob')
      assert json.key?('first_name')
      assert json.key?('height_in_cm')
      assert json.key?('weight_in_kg')
      assert json.key?('phone')
      assert json.key?('addresses')
      assert json.key?('identification')
      assert json.key?('payment_method')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

  it 'users#show w/ rfid' do
    user = User.first
    get api_v1_user_path(user.rfid), headers: authenticated_header
    assert_response :success
    assert parsed_response.key?('data')
    assert parsed_response.dig('data')

    parsed_response.dig('data') do |json|
      assert json.key?('id')
      assert json.key?('email')
      assert json.key?('dob')
      assert json.key?('first_name')
      assert json.key?('height_in_cm')
      assert json.key?('weight_in_kg')
      assert json.key?('phone')
      assert json.key?('addresses')
      assert json.key?('identification')
      assert json.key?('payment_method')
      refute json.key?('code')
      refute json.key?('message')
      refute json.key?('errors')
    end
  end

  it "users#errors => record not found" do
    user = Hash(id: 12345)

    delete api_v1_user_path(user[:id]), headers: authenticated_header
    assert_response :not_found

    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

  it 'users#errors => unauthorized' do
    get api_v1_users_path, headers: bad_auth_header
    assert_response :unauthorized

    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

end
