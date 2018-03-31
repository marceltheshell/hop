require 'test_helper'

class Api::V1::BootTest < ActionDispatch::IntegrationTest
  let(:secured_route) { api_secured_path }
  let(:user_creds) { Hash(email: "test1_user_role@test.com", password: "123456", phone:"3153456050") }
  let(:service_creds) { Hash(email: "employee-app@test.com", password: "123456") }
  let(:service_pin) { Hash(email: "employee-pin@test.com", pin: "456789") }

  #
  # Login as service user, return jwt token
  #
  def service_user_token
    ServiceUser.create!(service_creds)
    post api_v1_boot_path, params: Hash(auth: service_creds)
    assert_response :success
    parsed_response.dig('data', 'jwt')
  end

  it "user calls /boot" do
    User.create!(user_creds)
    post api_v1_boot_path, params: Hash(auth: user_creds)
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').key?('access')
      assert json.dig('data', 'errors').key?('access')
      assert json.dig('data', 'errors').is_a?(Hash)
    end

  end

  it "auth with only valid RFID" do
    ServiceUser.create!( service_creds.merge(rfid: "123456") )
    post api_v1_boot_path, params: Hash(auth: {rfid: "123456"})

    assert_response :success
    assert parsed_response.dig('data', 'jwt').present?
  end

  it "failed RFID auth" do
    ServiceUser.create!( service_creds.merge(rfid: "123456") )
    post api_v1_boot_path, params: Hash(auth: {rfid: "123456ABC"})

    assert_response :unauthorized
  end

  it "service user calls /boot" do
    ServiceUser.create!(service_creds)
    post api_v1_boot_path, params: Hash(auth: service_creds)
    assert_response :success
    assert parsed_response.dig('data', 'jwt').present?
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

  it 'is authorized with valid token' do
    token = boot_as( users(:service).email )
    get secured_route, headers: authenticated_header(token: token)
    assert_response :success
  end

  it "is authorized with matching 6 digits pin" do
    ServiceUser.create!(service_pin)
    post api_v1_boot_path, params: Hash(auth: service_pin)
    assert_response :success
    assert parsed_response.dig('data', 'jwt').present?
  end

  it "is unauthorized with invalid pin and valid email" do
    ServiceUser.create!(service_pin)
    post api_v1_boot_path, params: Hash(auth: {email: service_pin[:email], pin: "123456"})
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

  it "is unauthorized with invalid rfid and a valid email" do
    service_user = ServiceUser.create!( service_creds.merge(rfid: "123456") )
    post api_v1_boot_path, params: Hash(auth: {email: service_user[:email], rfid: "654321"} )
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

  it "is unauthorized with invalid password and a valid email" do
    service_creds[:password] = nil
    server = ServiceUser.create!( service_creds )
    post api_v1_boot_path, params: Hash(auth: service_creds)
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

  it "is unauthorized with missing password field" do
    service_creds.except!(:password)
    server = ServiceUser.create!( service_creds )
    post api_v1_boot_path, params: Hash(auth: service_creds)
    assert_response :unauthorized
    parsed_response do |json|
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').is_a?(Hash)
    end
  end

end
