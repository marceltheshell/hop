require 'test_helper'

class Transaction::CreditTest < ActiveSupport::TestCase
  let(:user) { users(:two) }

  it "credit#create w/ amount_in_cents < 0" do
    balance = user.current_balance
    credit  = user.credits.create!(amount_in_cents: -200)
  
      assert_equal balance, user.current_balance - credit[:amount_in_cents]
      assert_equal balance, user.current_balance + credit[:amount_in_cents].abs
      assert_equal Transaction::Credit, credit.class
  end

  it "credit#create w/ amount_in_cents > 0" do
    balance = user.current_balance
    credit  = user.credits.create!(amount_in_cents: 200)

      assert_equal balance, user.current_balance - credit[:amount_in_cents]
      assert_equal balance, user.current_balance + credit[:amount_in_cents].abs
      assert_equal Transaction::Credit, credit.class
  end


end
