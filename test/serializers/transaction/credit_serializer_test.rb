require 'test_helper'

class Transaction::CreditSerializerTest < ActiveSupport::TestCase
  let(:credit) { user_transactions(:credit) }

  it "credit#create => creditSerializer" do
    Transaction::CreditSerializer.new( credit ).as_json do |json|
      assert json.key?('credit')

      json.dig('credit').tap do |json|
        assert json.key?('id')
        assert json.key?('balance_in_cents')
        assert json.key?('credit_at')
        assert json.key?('metadata')

        json.dig('metadata').tap do |meta|
          assert meta.key?('Token')
          assert meta.key?('GatewayTransID')
          assert meta.key?('AuthorizedAmount')
        end
      end
    end
  end

  it "CreditSerializer with amount_in_cents > 0" do
    user = users(:two)
    credit = user.credits.create!(amount_in_cents: 1000)

    Transaction::CreditSerializer.new( credit ).as_json do |json|
      assert json.key?('credit')

      json.dig('credit').tap do |json|
        assert json.key?('id')
        assert json.key?('balance_in_cents')
        assert json.key?('credit_at')
        assert json.key?('metadata')
      end
    end
  end
end
