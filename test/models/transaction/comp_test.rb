require 'test_helper'

class Transaction::CompTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

  it "user#current_balance" do
    balance = user.current_balance
    comp = user.comps.create!(amount_in_cents: 1700)
    new_balance = user.current_balance

      assert_equal new_balance, (balance + comp[:amount_in_cents])
      assert_equal new_balance, user.calculated_balance
      assert_match 'Transaction::Comp', comp[:type]
  end

  it "user#calculated_balance" do
    calc_balance = user.calculated_balance
    comp = user.comps.create!(amount_in_cents: 2500) #same as Transaction::Comp.create!(user:user,  amount_in_cents: 2500)
    new_calculated_bal = user.calculated_balance

      assert_equal new_calculated_bal, (calc_balance + comp[:amount_in_cents])
      assert_equal new_calculated_bal, user.current_balance
  end

  it "Has_attributes for Comp model" do
    comp = user.comps.last
      assert comp.has_attribute?(:user_id)
      assert comp.has_attribute?(:type)
      assert comp.has_attribute?(:description)
      assert comp.has_attribute?(:amount_in_cents)
      assert comp.has_attribute?(:balance_in_cents)
      assert comp.has_attribute?(:metadata)
      assert comp.has_attribute?(:created_at)
      assert comp.has_attribute?(:updated_at)
      assert comp.has_attribute?(:employee_id)
      assert comp.has_attribute?(:venue_id)
      assert comp.has_attribute?(:tap_id)
      assert comp.has_attribute?(:qty)
  end

  it "amount_in_cents < 0 gets processed as a positive amount" do
     balance = user.current_balance
     comp_amount = user.comps.create!(amount_in_cents: -1000)
     new_calculated_bal = user.calculated_balance

      assert_equal new_calculated_bal, user.current_balance
      assert_equal 1000, comp_amount[:amount_in_cents]
  end

  it "Raises exception when user_id is missing" do
    ex = assert_raises(ActiveRecord::RecordNotFound) {
        Transaction::Comp.create!(amount_in_cents: 1200)}
        assert_match %r{Couldn't find User without an ID}i, ex.message
  end

  it "user#calculated_balance should not be equal to sum of all :amount_in_cents for type=>comp " do
    comps = user.comps
      refute_equal user.calculated_balance, comps.sum(:amount_in_cents)
  end

end
