require 'test_helper'

class Api::V1::UsersUpdateTest < ActionDispatch::IntegrationTest
  let(:user) { users(:one) }

  let(:user_params) do
    Hash(
      email: "update-test@test.com",
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      height_in_cm: 100,
      weight_in_kg: 200,
      gender: "both",
      phone: "555-ass-kick",
      rfid: "1232456ABC"
    )
  end

  let(:address_params) do
    Hash(
      addresses: [{
        id: user.addresses.first.id,
        street1: "123 Chuck Norris Lane",
        city: "Chuck",
        state: "Norris",
        postal: "91111",
        country: "US"
      }]
    )
  end

  let(:identification) do
    Hash(
      identification: {
        id: user.identification.id,
        issuer: "US Passport",
        expires_at: "2017-12-12"
      }
    )
  end

  let(:payment_method) do
    Hash(
      payment_method: {
        id: user.payment_method.id,
        card_type: 'mastercard',
        expires_at: '2017-12-12',
        name_on_card: 'Chuck N Norris',
        token: SecureRandom.hex(8),
        masked_number: "xxxxxxx5555"
      }
    )
  end

  it "updates user fields and enqueues qr_code jobs" do
    user = users(:one)
    assert_no_difference 'User.count' do
      put api_v1_user_path(user.id), params: Hash(user: user_params), headers: authenticated_header
    end

    assert_response :success
    assert_equal 1, QrCodeJob.jobs.size
    assert_equal 1, RemoveQrCodeJob.jobs.size

    user = User.find( user.id )
    assert_equal "update-test@test.com", user.email
    assert_equal "Chuck", user.first_name
    assert_equal "Kick-Your-Arse", user.middle_name
    assert_equal "Norris", user.last_name
    assert_equal 100, user.height_in_cm
    assert_equal 200, user.weight_in_kg
    assert_equal "both", user.gender
    assert_equal "555-ass-kick", user.phone
    assert_equal "1232456ABC", user.rfid
  end

  it "updates user address fields" do
    user_data = address_params

    assert_no_difference ['User.count', 'Address.count'] do
      put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
      assert_response :success
    end

    address = User.find( user.id ).addresses.first
    assert_equal "123 Chuck Norris Lane", address.street1
    assert_equal "Chuck", address.city
    assert_equal "Norris", address.state
    assert_equal "91111", address.postal
  end

  it "updates identification fields" do
    user_data = identification

    assert_no_difference ['User.count', 'Identification.count'] do
      put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
      assert_response :success
    end

    identity = User.find( user.id ).identification
    assert_equal "US Passport", identity.issuer
    assert_equal Date.parse("2017-12-12"), identity.expires_at
  end

  it "updates payment method fields" do
    user_data = payment_method

    assert_no_difference ['User.count', 'PaymentMethod.count'] do
      put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
      assert_response :success
    end

    pay = User.find( user.id ).payment_method
    assert_equal "mastercard", pay.card_type
    assert_equal "Chuck N Norris", pay.name_on_card
    assert_equal Date.parse("2017-12-12"), pay.expires_at
    assert_equal "xxxxxxx5555", pay.masked_number
    refute pay.token.blank?
  end

  it "updates when no payment_method exist" do
    user.payment_method.destroy
    user.reload
    assert user.payment_method.nil?

    user_data = Hash(
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      payment_method: {
        token: "123",
        expires_at: Date.tomorrow
      }
    )

    put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
    assert_response :success

    User.find( user.id ).tap do |user|
      assert_equal "Chuck", user.first_name
      assert_equal "Norris", user.last_name
      refute user.payment_method.nil?
      assert user.payment_method.id.present?
    end
  end

  it "updates when no identification exist" do
    user.identification.destroy
    user.reload
    assert user.identification.nil?

    user_data = Hash(
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      identification: {
        expires_at: Date.tomorrow
      }
    )

    put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
    assert_response :success

    User.find( user.id ).tap do |user|
      assert_equal "Chuck", user.first_name
      assert_equal "Norris", user.last_name
      refute user.identification.nil?
      assert user.identification.id.present?
    end
  end

  it "updates when no addresses exist" do
    user.addresses.destroy_all
    assert_equal 0, user.addresses.count

    user_data = Hash(
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      addresses: [
        street1: "123 Chuck Norris Lane",
        city: "Chuck",
        state: "Norris",
        postal: "91111",
        country: "US"
      ]
    )

    put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
    assert_response :success

    User.find( user.id ).tap do |user|
      assert_equal 1, user.addresses.count
      assert_equal "Chuck", user.first_name
      assert_equal "Norris", user.last_name
    end
  end

  it "fails to update address without country field" do
    user.addresses.destroy_all
    assert_equal 0, user.addresses.count

    user_data = Hash(
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      addresses: [
        street1: "123 Chuck Norris Lane",
        city: "Chuck",
        state: "Norris",
        postal: "91111",
        address_type: "home"
      ]
    )

    put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
    assert_response :unprocessable_entity
    assert parsed_response.dig('data').key?('code')
    assert parsed_response.dig('data').key?('message')
    assert parsed_response.dig('data').key?('errors')
    assert parsed_response.dig('data', 'errors', 'home_address').key?('country')
    assert_match %r{can't be blank}i,  parsed_response.dig('data', 'errors', 'home_address', 'country').join
  end

  it "fails to update expired identification" do
    user.identification.destroy
    user.reload
    assert user.identification.nil?

    user_data = Hash(
      first_name: "Chuck",
      middle_name: "Kick-Your-Arse",
      last_name: "Norris",
      identification: {
        expires_at: Date.yesterday
      }
    )

    put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header

    assert_response :unprocessable_entity
    assert parsed_response.dig('data').key?('code')
    assert parsed_response.dig('data').key?('message')
    assert parsed_response.dig('data').key?('errors')
    assert_match %r{Expired identification}i, parsed_response.dig('data', 'errors', 'identification', 'expires_at').join
  end

  it "fails to update user without required fields" do
    required_fields = [ :email, :phone ]
    params = user_params.except( *required_fields )

    assert_no_difference 'User.count' do
      post api_v1_users_path, params: Hash(user: params), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data', 'errors', 'phone').present?
      assert json.dig('data', 'errors', 'email').present?
      assert_match %r{can't be blank}i, json.dig('data', 'errors', 'phone').join
      assert_match %r{can't be blank}i, json.dig('data', 'errors', 'email').join
    end
  end

  it "removes ids w/ nil value from association params" do
    identification[:identification][:id] = nil
    address_params[:addresses][0][:id] = nil
    payment_method[:payment_method][:id] = nil
    user_data = user_params.merge(identification).merge(address_params).merge(payment_method)

    assert_no_difference ['User.count'] do
      put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
      assert_response :success
      refute parsed_response.dig('data', 'errors').present?
    end
  end

  it "removes ids w/ nil value in multiple addresses" do
    other_addresses = [{ id: nil, country: "AU" }, { id: nil,country: "AU" }]
    address_params[:addresses][0][:id] = nil
    address_params[:addresses].concat(other_addresses)
    user_data = user_params.merge(address_params)

    assert_no_difference ['User.count'] do
      put api_v1_user_path(user.id), params: Hash(user: user_data), headers: authenticated_header
      assert_response :success
      refute parsed_response.dig('data', 'errors').present?
    end
  end

end
