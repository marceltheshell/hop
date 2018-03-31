require 'test_helper'

class DrinkCommand::ChargeSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }
  let(:charge) { BridgePayHelper.charge_user(user, 500) }

  it "#as_json" do
    DrinkCommand::ChargeSerializer.new( charge ).as_json do |json|
      assert json.key?('amount_in_cents')
      assert json.key?('balance_in_cents')
      assert json.key?('reference_number')
    end
  end
end
