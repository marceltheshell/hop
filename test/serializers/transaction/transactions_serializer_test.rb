require 'test_helper'

class Transaction::TransactionsSerializerTest < ActiveSupport::TestCase
  let(:transactions) { UserTransaction.page(1).per(10)  }

  it "TransactionsSerializer" do
    Transaction::TransactionsSerializer.new( transactions ).as_json do |json|
      assert json.key?('transactions')
      json.dig('transactions')[0].tap do |json|
        assert json.key?('id')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
        assert json.key?('type')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
        assert json.key?('description')
        assert json.key?('tap_id')
        assert json.key?('qty')
        assert json.key?('venue_id')
        assert json.key?('created_at')
      end
    end
  end

end
