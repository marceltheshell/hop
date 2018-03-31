module AuthHelper
  #
  # Generate an authentication header
  #
  def authenticated_header( token: nil, user: nil )    
    user  ||= users(:service)
    token ||= user.to_service_token.token

    Hash('Authorization': "Bearer #{token}")
  end

  #
  # Login as "service user"
  #
  def boot_as(email, password="123456")
    post api_v1_boot_path, params: Hash(auth: {email: email, password: password})
    assert_response :success

    parsed_response.dig('data', 'jwt')
  end

  #
  # Login as "user"
  #
  def login_as(email, password="123456")
    post api_v1_auth_path, params: Hash(auth: {email: email, password: password})
    assert_response :success

    parsed_response.dig('data', 'jwt')
  end
end
