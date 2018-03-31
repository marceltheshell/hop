require 'test_helper'

class UserTransactionTest < ActiveSupport::TestCase

  it "Raises exception when user is missing" do
    ex = assert_raises(ActiveRecord::RecordNotFound) {
      UserTransaction.create!(amount_in_cents: 1000) }
      assert_match %r{Couldn't find User without an ID}i, ex.message
    end

  it "Raises exception if transaction causes balance to fall below zero" do
    user = User.last
    UserTransaction.create!(amount_in_cents: 1000, user: user)
    ex = assert_raises(ActiveRecord::RecordInvalid) {
      UserTransaction.create!(amount_in_cents: -1200, user: user)}
      assert_match %r{Balance in cents must be greater than or equal to 0}i, ex.message
    end

  it "user#calculated_balance" do

    user = User.first
    transactions = UserTransaction.where(user: user)
    assert_equal user.calculated_balance, transactions.sum(:amount_in_cents)
  end

  it "user#current_balance " do

    user = User.first
    bal = user.user_transactions.last.try(:balance_in_cents).to_i
    UserTransaction.create!(user: user, amount_in_cents: 1000)
    t = UserTransaction.where(user: user).last
    b = user.current_balance
    assert_equal b, t[:balance_in_cents]
  end

  it "Includes UserTransaction table columns" do
    assert UserTransaction.column_names.include? 'user_id'
    assert UserTransaction.column_names.include? 'type'
    assert UserTransaction.column_names.include? 'description'
    assert UserTransaction.column_names.include? 'amount_in_cents'
    assert UserTransaction.column_names.include? 'balance_in_cents'
    assert UserTransaction.column_names.include? 'metadata'
    assert UserTransaction.column_names.include? 'created_at'
    assert UserTransaction.column_names.include? 'updated_at'
    assert UserTransaction.column_names.include? 'employee_id'
    assert UserTransaction.column_names.include? 'venue_id'
    assert UserTransaction.column_names.include? 'tap_id'
    assert UserTransaction.column_names.include? 'qty'
  end

end
