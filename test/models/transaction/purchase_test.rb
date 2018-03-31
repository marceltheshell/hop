require 'test_helper'

class Transaction::PurchaseTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

  it "user#current_balance" do
    balance = user.current_balance
    last_purchase = user.purchases.create!(amount_in_cents: -1700)
    new_balance = user.current_balance
      assert_equal balance, (new_balance - last_purchase[:amount_in_cents])
      assert_equal new_balance, user.calculated_balance
      assert_match 'Transaction::Purchase', last_purchase[:type]
  end

  it "user#calculated_balance" do
    calc_balance = user.calculated_balance
    last_purchase = user.purchases.create!(amount_in_cents: -2500)
    new_calculated_bal = user.calculated_balance

      assert_equal calc_balance, (new_calculated_bal - last_purchase[:amount_in_cents])
      assert_equal new_calculated_bal, user.current_balance
  end

  it "Has_attributes for Purchase model" do
    purchase = user.purchases.last

      assert purchase.has_attribute?(:user_id)
      assert purchase.has_attribute?(:type)
      assert purchase.has_attribute?(:description)
      assert purchase.has_attribute?(:amount_in_cents)
      assert purchase.has_attribute?(:balance_in_cents)
      assert purchase.has_attribute?(:metadata)
      assert purchase.has_attribute?(:created_at)
      assert purchase.has_attribute?(:updated_at)
      assert purchase.has_attribute?(:employee_id)
      assert purchase.has_attribute?(:venue_id)
      assert purchase.has_attribute?(:tap_id)
      assert purchase.has_attribute?(:qty)
  end

  it "Raises exception if transaction causes balance to fall below zero" do
    ex = assert_raises(ActiveRecord::RecordInvalid) {
      user.purchases.create!(amount_in_cents: -40000)}
      assert_match %r{Balance in cents must be greater than or equal to 0}i, ex.message
  end

  it "Raises exception when user is missing" do
    ex = assert_raises(ActiveRecord::RecordNotFound) {
      Transaction::Purchase.create!(amount_in_cents: 1200)}
      assert_match %r{Couldn't find User without an ID}i, ex.message
  end

  it "Processes purchase w/ :amount_in_cents > 0" do
    balance = user.current_balance
    purchase = user.purchases.create!(amount_in_cents: 1000)
    new_balance = user.current_balance

      assert_equal balance, (new_balance - purchase[:amount_in_cents])
      assert_equal new_balance, user.calculated_balance
      assert_equal Transaction::Purchase, purchase.class
  end

  it "user#calculated_balance should not be equal to sum of all :amount_in_cents for type=>purchase " do
    purchases = user.purchases
      refute_equal user.calculated_balance, purchases.sum(:amount_in_cents)
  end

end
