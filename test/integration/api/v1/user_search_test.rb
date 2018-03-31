require 'test_helper'

class Api::V1::UserSearchTest < ActionDispatch::IntegrationTest

  def behaves_like_found_one_user
    assert_response :success
    parsed_response do |json|
      assert_equal 1, json.dig('data', 'total')
      assert_equal 1, json.dig('data', 'pages')
    end
  end

  it "find user by RFID" do
    get api_v1_users_path, params:{q:'abcd1234'}, headers: authenticated_header
    behaves_like_found_one_user
  end

  it "find user by Email" do
    get api_v1_users_path, params:{q:'55555@test.com'}, headers: authenticated_header
    behaves_like_found_one_user
  end

  it "find user by Phone" do
    get api_v1_users_path, params:{q:'9543534443'}, headers: authenticated_header
    behaves_like_found_one_user
  end

  it "does not find deactivated users" do
    User.find_each(&:deactivate!)
    get api_v1_users_path, params:{q:'abcd1234'}, headers: authenticated_header

    assert_response :success
    parsed_response do |json|
      assert_equal 0, json.dig('data', 'total')
      assert_equal 0, json.dig('data', 'pages')
    end
  end
end
