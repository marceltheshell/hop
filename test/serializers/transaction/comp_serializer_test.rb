require 'test_helper'

class Transaction::CompSerializerTest < ActiveSupport::TestCase
  let(:comp) { user_transactions(:comp) }

  it "comp#create => CompSerializer" do
    Transaction::CompSerializer.new( comp ).as_json do |json|
      assert json.key?('comp')
      json.dig('comp').tap do |json|
        assert json.key?('id')
        assert json.key?('comp_at')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
        assert json.key?('venue_id')
        assert json.key?('employee_id')
      end
    end
  end

  it "CompSerializer with amount_in_cents < 0" do
    user = users(:two)
    comp = user.comps.create!(amount_in_cents: -1000)

    Transaction::CompSerializer.new( comp ).as_json do |json|
      assert json.key?('comp')
      json.dig('comp').tap do |json|
        assert json.key?('id')
        assert json.key?('amount_in_cents')
        assert json.key?('balance_in_cents')
      end
    end
  end

end
