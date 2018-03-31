require 'test_helper'

class Transaction::ChargeSerializerTest < ActiveSupport::TestCase
  let(:charge) { user_transactions(:charge) }

  it "charge#create => ChargeSerializer" do
    Transaction::ChargeSerializer.new( charge ).as_json do |json|
      assert json.key?('charge')
      json.dig('charge').tap do |json|
        assert json.key?('id')
        assert json.key?('metadata')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')

        json.dig('metadata').tap do |meta|
          assert meta.key?('Token')
          assert meta.key?('GatewayTransID')
          assert meta.key?('AuthorizedAmount')
        end
      end
    end
  end

  it "ChargeSerializer with amount_in_cents < 0" do
    user = users(:two)
    chrg = user.charges.create!(amount_in_cents: -1000)
    Transaction::ChargeSerializer.new( chrg ).as_json do |json|

      assert json.key?('charge')
      json.dig('charge').tap do |json|
        assert json.key?('id')
        assert json.key?('metadata') # no mock response
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
      end
    end
  end

end
