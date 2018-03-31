require 'test_helper'

class Transaction::ChargeTest < ActiveSupport::TestCase
  
  it "user#current_balance" do
    user        = User.first
    balance     = user.current_balance
    last_charge = user.charges.create!(amount_in_cents: 1700)
    new_balance = user.current_balance

    assert_equal balance, (new_balance - last_charge[:amount_in_cents])
    assert_equal new_balance, user.calculated_balance
    assert_match 'Transaction::Charge', last_charge[:type]
  end

  it "user#calculated_balance" do
    user               = User.first
    calc_balance       = user.calculated_balance
    last_charge        = user.charges.create!(amount_in_cents: 2500 )
    new_calculated_bal = user.calculated_balance

    assert_equal calc_balance, (new_calculated_bal - last_charge[:amount_in_cents])
    assert_equal new_calculated_bal, user.current_balance
  end

  it "amount_in_cents < 0 gets processed as a positive amount" do
     user = User.first
     balance = user.current_balance
     chrg_amount = user.charges.create!(amount_in_cents: -1000)
     new_calculated_bal = user.calculated_balance

      assert_equal new_calculated_bal, user.current_balance
      assert_equal 1000, chrg_amount[:amount_in_cents]
  end

  it "Raises exception if transaction causes balance to fall below zero" do
    user = User.first
    user.charges.create!(amount_in_cents: 900)

    ex = assert_raises(ActiveRecord::RecordInvalid) do
      Transaction::Purchase.create!(user:user,  amount_in_cents: -40000)
    end
    assert_match %r{Balance in cents must be greater than or equal to 0}i, ex.message
  end

  it "Raises exception when user_id is missing" do
    ex = assert_raises(ActiveRecord::RecordNotFound) {
      Transaction::Charge.create!(amount_in_cents: 1200)}
      assert_match %r{Couldn't find User without an ID}i, ex.message
  end

  it "user#calculated_balance should not be equal to sum of all :amount_in_cents for type=>charge " do
    user = User.first
    user.charges.create!(amount_in_cents: -1500)
    user.purchases.create!(amount_in_cents: -500)
    refute_equal user.calculated_balance, user.charges.sum(:amount_in_cents)
  end
end
