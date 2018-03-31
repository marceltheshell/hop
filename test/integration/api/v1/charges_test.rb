require 'test_helper'

class Api::V1::ChargesTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }
  let(:payment_method) { payment_methods(:default) }
  let(:charge_params) { Hash(amount_in_cents: 500) }

  it 'charges#create success' do
    previous_balance = user.current_balance
    VCR.use_cassette("bridgepay-charge") do
      post api_v1_charges_path(user.id), params: Hash(charge: charge_params), headers: authenticated_header
    end

    assert_response :created
    assert_equal (previous_balance+500), user.current_balance
  end

  it 'sends charge email with new charge'do
    assert_equal 0, Sidekiq::Extensions::DelayedMailer.jobs.size
    VCR.use_cassette("bridgepay-charge") do
      post api_v1_charges_path(user.id), params: Hash(charge: charge_params), headers: authenticated_header
    end

    email_type = Sidekiq::Extensions::DelayedMailer.jobs.last["args"][0].slice(":charge_email")
    assert_response :success
    assert_equal 1, Sidekiq::Extensions::DelayedMailer.jobs.size
    assert_match %r{:charge_email}, email_type
  end

  it 'charges#create processes charge amount_in_cents < 0 as a positive' do
    previous_balance = user.current_balance
    charge = Hash(amount_in_cents: -500)

    VCR.use_cassette("bridgepay-charge") do
      post api_v1_charges_path(user.id), params: Hash( charge: charge), headers: authenticated_header
    end
    assert_response :success
    assert_equal previous_balance + 500, user.current_balance
  end

  it 'charges#create denied failure' do
    VCR.use_cassette("bridgepay-charge-denied") do
      post api_v1_charges_path(user.id), params: Hash(charge: charge_params), headers: authenticated_header
    end

    assert_response :not_acceptable
  end

  it 'renders error when payment details are missing' do
    user.payment_method.destroy # remove payment method from users account
    post api_v1_charges_path(user.id), params: Hash(charge: charge_params), headers: authenticated_header

    assert_response :not_acceptable
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').key?('payment')
    end
  end

  it 'renders error when user is missing' do
    post api_v1_charges_path('123'), params: Hash(charge: charge_params), headers: authenticated_header

    assert_response :not_found
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').key?('user')
    end
  end

  it "Raises error when empty params" do
    VCR.use_cassette("bridgepay-charge") do
      post api_v1_charges_path(user.id), params: Hash( charge: {}), headers: authenticated_header
    end

    assert_response 422
    parsed_response do |json|
      assert json.key?('data')
      assert_match %r{Missing Params}i, json.dig('data', 'errors', 'record').join
    end
  end

end
