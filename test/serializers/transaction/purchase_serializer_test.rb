require 'test_helper'

class Transaction::PurchaseSerializerTest < ActiveSupport::TestCase
  let(:purchase) { user_transactions(:purchase) }

  it "purchase#create => PurchaseSerializer" do
    Transaction::PurchaseSerializer.new( purchase ).as_json do |json|

      assert json.key?('purchase')
      json.dig('purchase').tap do |json|
        assert json.key?('id')
        assert json.key?('purchased_at')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
        assert json.key?('venue_id')
        assert json.key?('qty')
        assert json.key?('tap_id')
      end
    end
  end

  it "PurchaseSerializer with amount_in_cents > 0" do
    user = users(:two)
    purchase = user.purchases.create!(amount_in_cents: 1200)

    Transaction::PurchaseSerializer.new( purchase ).as_json do |json|
      assert json.key?('purchase')
      json.dig('purchase').tap do |json|
        assert json.key?('id')
        assert json.key?('purchased_at')
        assert json.key?('balance_in_cents')
      end
    end
  end

end
