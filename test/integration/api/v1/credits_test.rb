require 'test_helper'

class Api::V1::CreditsTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }
  let(:payment_method) { payment_methods(:default) }
  let(:credit_params) { Hash(amount_in_cents: 500) }

  it 'credits#create success' do
    previous_balance = user.current_balance

    VCR.use_cassette("bridgepay-credit") do
      post api_v1_credits_path(user.id), params: Hash(credit: credit_params), headers: authenticated_header
    end

    assert_response :created
    assert_equal (previous_balance-500), user.current_balance

    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('credit')
      assert json.dig('data', 'credit').key?('metadata')
    end
  end

  it 'credits#create denied failure' do
    previous_balance = user.current_balance

    VCR.use_cassette("bridgepay-credit-denied") do
      post api_v1_credits_path(user.id), params: Hash(credit: credit_params), headers: authenticated_header
    end

    assert_response :not_acceptable
    assert_equal previous_balance, user.current_balance #  no change in balance
  end

  it 'renders error when payment details are missing' do
    user.payment_method.destroy # remove payment method from users account
    post api_v1_credits_path(user.id), params: Hash(credit: credit_params), headers: authenticated_header

    assert_response :not_acceptable
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert_equal 10011, json.dig('data', 'code')
      assert_match %r{Payment information failure}i, json.dig('data', 'message')
      assert json.dig('data', 'errors').key?('payment')
    end
  end

  it 'renders error when user is missing' do
    post api_v1_credits_path('123'), params: Hash(credit: credit_params), headers: authenticated_header

    assert_response :not_found
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data', 'errors').key?('user')
      assert_match %r{not found}i, json.dig('data', 'errors', 'user').join
    end
  end
end
