require 'test_helper'

class Api::V1::RoleTest < ActionDispatch::IntegrationTest
  let(:secured_route) { api_secured_path }

  it "when role=service" do
    token = boot_as( users(:service).email )

    get secured_route, headers: authenticated_header(token: token)
    assert_response :success
  end

  it "when role=user" do
    token = login_as("test@test.com")

    get secured_route, headers: authenticated_header(token: token)
    assert_response :unauthorized
  end
end
