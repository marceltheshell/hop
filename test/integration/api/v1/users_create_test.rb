require 'test_helper'

class Api::V1::UsersCreateTest < ActionDispatch::IntegrationTest
  let(:user_params) do
    Hash(
      email: 'test-user-3@test.com',
      password: '123456',
      first_name: 'tess',
      last_name: 'testerine',
      middle_name: 't',
      height_in_cm: 183,
      weight_in_kg: 86,
      gender: 'male',
      phone: '95435399995',
      rfid: 'abcd1234A'
    )
  end

  let(:address_params) do
    Hash(
      'street1': Faker::Address.street_address,
      'city': Faker::Address.city,
      'state': Faker::Address.state,
      'country': Faker::Address.country,
      'postal': Faker::Address.postcode
    )
  end

  let(:identification_params) do
    Hash(
      identification_type: 'license',
      issuer: 'DMV',
      expires_at: 1.year.from_now.to_date
    )
  end

  let(:payment_params) do
    Hash(
      card_type: "visa",
      expires_at: 1.year.from_now.to_date ,
      name_on_card: "test user",
      token: SecureRandom.hex(8),
      masked_number: "xxxxxxx5555"
    )
  end

  it 'creates a user and enqueues qr_code jobs' do
    assert_difference 'User.count' do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response :success
    assert_equal 1, QrCodeJob.jobs.size
    assert_equal 0, RemoveQrCodeJob.jobs.size
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'user').key?('id')
      assert json.dig('data', 'user').key?('type')
    end
  end

  it 'sends welcome email to new users' do
    assert_equal 0, Sidekiq::Extensions::DelayedMailer.jobs.size
    assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size', +1 do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    email_type = Sidekiq::Extensions::DelayedMailer.jobs.last["args"][0].slice(":welcome_email")
    assert_response :success
    assert_equal 1, Sidekiq::Extensions::DelayedMailer.jobs.size
    assert_match %r{:welcome_email}, email_type
  end

  it 'does not create user without required fields' do
    required_fields = [:email, :phone]
    params = user_params.except( *required_fields )

    assert_no_difference 'User.count' do
      post api_v1_users_path, params: Hash(user: params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'email').present?
      assert json.dig('data', 'errors', 'phone').present?
      assert_match %r{can't be blank}i, json.dig('data', 'errors', 'phone').join
      assert_match %r{can't be blank}i, json.dig('data', 'errors', 'email').join
    end
  end

  it 'saves an address too' do
    user_params.merge!(addresses: [address_params])

    assert_difference ['User.count', 'Address.count'] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response :success
    parsed_response.dig('data', 'user', 'addresses')[0].key?('street1')
    parsed_response.dig('data', 'user', 'addresses')[0].key?('city')
    parsed_response.dig('data', 'user', 'addresses')[0].key?('state')
    parsed_response.dig('data', 'user', 'addresses')[0].key?('postal')
  end

  it 'does not save with failing address' do
    address = address_params.except(:country)
    params  = user_params.merge(addresses: [address])

    assert_no_difference ['User.count', 'Address.count'] do
      post api_v1_users_path, params: Hash(user: params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'default_address', 'country').present?
    end
  end

  it 'saves an identification too' do
    user_params.merge!(identification: identification_params)

    assert_difference ['User.count', 'Identification.count'] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response :success
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('user')
      assert json.dig('data', 'user').key?('id')
      assert json.dig('data', 'user').key?('type')
    end
  end

  it 'doesn\'t save with failing identification' do
    user_params.merge!(identification: {expires_at: nil})

    assert_no_difference ['User.count', 'Identification.count'] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'identification', 'expires_at').present?
    end
  end

  it 'only returns associations w/ errors' do
    user_params.merge!(
      identification: {
        expires_at: nil
      },
      payment_method: {
        expires_at: "2020-01-01",
        token:"1234"
      },
      addresses: [{
        country: "USA"
      }]
    )

    assert_no_difference ['User.count', 'Identification.count', 'PaymentMethod.count', 'Address.count' ] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'identification', 'expires_at').present?
      refute json.dig('data', 'errors').key?('payment_method')
      refute json.dig('data', 'errors').key?('addresses')
    end
  end

  it 'saves an payment method too' do
    user_params.merge!(payment_method: payment_params)

    assert_difference ['User.count', 'PaymentMethod.count'] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response :success
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'user', 'payment_method').present?
      assert json.dig('data', 'user', 'payment_method').key?('card_type')
      assert json.dig('data', 'user', 'payment_method').key?('masked_number')
      assert_equal "xxxxxxx5555", json.dig('data', 'user', 'payment_method', 'masked_number')
    end
  end

  it 'doesn\'t save with failing payment method' do
    user_params.merge!(payment_method: payment_params.except(:token))

    assert_no_difference ['User.count', 'PaymentMethod.count'] do
      post api_v1_users_path, params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'payment_method', 'token').present?
    end
  end

  it "Raises error when empty params" do
    assert_no_difference ['User.count', 'PaymentMethod.count'] do
      post api_v1_users_path, params: Hash(user: {}), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert_match %r{Missing Params}i, json.dig('data', 'errors', 'record').join
    end
  end

end
