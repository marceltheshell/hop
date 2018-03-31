require 'test_helper'

class Transaction::RefundTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

    it "user#current_balance" do
      balance = user.current_balance
      refund = user.refunds.create!(amount_in_cents: -1700)
      new_balance = user.current_balance

        assert_equal balance, (new_balance - refund[:amount_in_cents])
        assert_equal new_balance, user.calculated_balance
        assert_match 'Transaction::Refund', refund[:type]
    end

    it "user#calculated_balance" do
      calc_balance = user.calculated_balance
      refund = user.refunds.create!(amount_in_cents: -2500)
      new_calculated_bal = user.calculated_balance

        assert_equal calc_balance, (new_calculated_bal - refund[:amount_in_cents])
        assert_equal new_calculated_bal, user.current_balance
    end

    it "Raises exception if refund causes balance to fall below zero" do
      ex = assert_raises(ActiveRecord::RecordInvalid) {
        user.refunds.create!(amount_in_cents: -40000)}
        assert_match %r{Balance in cents must be greater than or equal to 0}i, ex.message
    end

    it "Raises exception when user is missing before validating ':amount_in_cents type:refund is <= 0' " do
      ex = assert_raises(ActiveRecord::RecordNotFound) {
        Transaction::Refund.create!(amount_in_cents: 1200)}
        assert_match %r{Couldn't find User without an ID}i, ex.message
    end

    it "Processes refund w/ :amount_in_cents > 0" do
      balance = user.current_balance
      refund = user.refunds.create!(amount_in_cents: 1000)
      new_balance = user.current_balance

        assert_equal balance, (new_balance - refund[:amount_in_cents])
        assert_equal new_balance, user.calculated_balance
        assert_equal Transaction::Refund, refund.class
    end

    it "user#calculated_balance should not be equal to sum of all :amount_in_cents for type=>refund " do
      refunds = user.refunds

        refute_equal user.calculated_balance, refunds.sum(:amount_in_cents)
    end

end
