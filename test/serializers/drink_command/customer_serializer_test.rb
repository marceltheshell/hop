require 'test_helper'

class DrinkCommand::CustomerSerializerTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

  it "#as_json" do
    DrinkCommand::CustomerSerializer.new( user ).as_json do |json|
      assert json.key?('first_name')
      assert json.key?('last_name')
      assert json.key?('name_on_card')
      assert json.key?('card_type')
      assert json.key?('masked_number')
      assert json.key?('expires_at')
      assert json.key?('balance_in_cents')
      assert json.key?('credit_limit_in_cents')
    end
  end

  it "credit limit equals users' balance when less than default limit" do
    assert user.current_balance < Settings.credit_limit_in_cents
    DrinkCommand::CustomerSerializer.new( user ).as_json do |json|
      assert_equal json.dig('balance_in_cents'), json.dig('credit_limit_in_cents')
    end
  end
end
