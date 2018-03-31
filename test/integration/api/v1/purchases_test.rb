require 'test_helper'

class Api::V1::PurchasesTest < ActionDispatch::IntegrationTest

  let(:user) { users(:two) }
  let(:purchase_params) do
      Hash(
        "user_id": user["id"],
        "amount_in_cents": -850,
        "qty": 20
      )
  end

  it 'purchases#create' do
    balance = user.current_balance

    assert_difference 'user.purchases.count' do
      post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
      new_balance = user.current_balance

      assert_response :created
      assert_equal user.current_balance, (balance + purchase_params[:amount_in_cents])
      assert_equal (new_balance - user.purchases.last[:amount_in_cents]), balance
    end

      parsed_response do |json|
        assert json.key?('data')
        assert json.dig('data', 'purchase').key?('id')
        assert json.dig('data', 'purchase').key?('amount_in_cents')
        assert json.dig('data', 'purchase').key?('balance_in_cents')
        assert json.dig('data', 'purchase').key?('purchased_at')
        assert json.dig('data', 'purchase').key?('venue_id')
        assert json.dig('data', 'purchase').key?('qty')
        assert json.dig('data', 'purchase').key?('tap_id')
      end

  end

  it 'purchases#create updates user#current_balance' do
    balance = user.current_balance
    assert_difference 'user.purchases.count' do
      post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header

    end
      refute_equal  user.current_balance, balance
      assert_equal  (balance + user.purchases.last[:amount_in_cents]), user.current_balance
  end

  it 'purchases#create w/ :amount_in_cents > 0' do
    balance = user.current_balance
    purchase_params = Hash(
      user_id: user.id,
      amount_in_cents: 1000
    )
    post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
      assert_response :success
      assert_equal  (balance + user.purchases.last[:amount_in_cents]), user.current_balance
  end

  it 'Raises exception when :amount_in_cents > 0 causes balance to fall below 0' do
    purchase_params = Hash(
      user_id: user.id,
      amount: 5000
    )
    post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
    assert_response :bad_request
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data', 'errors').key?('balance_in_cents')
      assert_match %r{must be greater than or equal to 0}i, json.dig('data','errors','balance_in_cents').join
    end
  end

  it 'Raises exception when :amount_in_cents < 0 causes balance to fall below 0' do
    purchase_params = Hash(
      user_id: user.id,
      amount_in_cents: -5000
    )
    post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
    assert_response :bad_request
    parsed_response do |json|
      assert json.key?('data')
      assert json.dig('data').key?('errors')
      assert json.dig('data').key?('code')
      assert json.dig('data').key?('message')
      assert json.dig('data', 'errors').key?('balance_in_cents')
      assert_match %r{must be greater than or equal to 0}i, json.dig('data','errors','balance_in_cents').join
    end
  end

  it 'Nil amount for purchases is processed as 0 ' do
    hop_balance = user.current_balance
    purchase_params = Hash(
      user_id: user.id,
      amount_in_cents: nil
    )
    post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
    assert_response :success
    assert parsed_response.dig('data', 'purchase').key?('id')
    assert parsed_response.dig('data', 'purchase').key?('amount_in_cents')
    assert parsed_response.dig('data', 'purchase').key?('balance_in_cents')
    assert_equal parsed_response.dig('data', 'purchase', 'amount_in_cents'), 0
    assert_equal parsed_response.dig('data', 'purchase', 'balance_in_cents'), hop_balance
  end

  it 'only amount_in_cents gets evaluated when both :amount and :amount_in_cents are present' do
    hop_balance = user.current_balance
    purchase_params = Hash(
      user_id: user.id,
      amount: 30000,
      amount_in_cents: 500
    )
    post api_v1_purchases_path(user.id), params: Hash(purchase: purchase_params), headers: authenticated_header
    assert_response :success
    assert parsed_response.dig('data', 'purchase').key?('id')
    assert parsed_response.dig('data', 'purchase').key?('amount_in_cents')
    assert parsed_response.dig('data', 'purchase').key?('balance_in_cents')
    assert_equal parsed_response.dig('data', 'purchase', 'amount_in_cents'), 500
    assert_equal parsed_response.dig('data', 'purchase', 'balance_in_cents'), hop_balance - 500
  end

end
