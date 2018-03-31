require 'test_helper'

class Api::V1::TransactionsTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }

  it 'transactions#index w/ user.id' do
    count = user.user_transactions.count
    get api_v1_transactions_path(user.id), headers: authenticated_header
    assert_response :success
    parsed_response do |json|
      assert_equal count, json.dig('data', 'total')
      assert_equal 1, json.dig('data', 'pages')
    end
  end

  it 'transactions#index w/ user.rfid' do
    count = user.user_transactions.count
    get api_v1_transactions_path(user.rfid), headers: authenticated_header
    assert_response :success
    parsed_response do |json|
      assert_equal count, json.dig('data', 'total')
      assert_equal 1, json.dig('data', 'pages')
    end
  end

  it 'transactions#index w/ pagination' do
    count = user.user_transactions.count # 6
    get api_v1_transactions_path(user.id), params:{page: 2, per_page: 3}, headers: authenticated_header
    assert_response :success
    parsed_response do |json|
      assert_equal count, json.dig('data', 'total') #all transactions count 3x2 = 6
      assert_equal 2, json.dig('data', 'pages')
      assert_equal 3, json.dig('data', 'transactions').count
    end
  end

  it "find transactions by type" do
    count = user.credits.count
    get api_v1_transactions_path(user.id), params:{q:'credit'}, headers: authenticated_header
    assert_response :success
    parsed_response do |json|
      assert_equal count, json.dig('data', 'total')
      assert_equal 1, json.dig('data', 'pages')
      assert_match %r{Transaction::Credit}, json.dig('data', 'transactions')[0]['type']
    end
  end

end
