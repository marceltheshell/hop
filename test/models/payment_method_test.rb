require 'test_helper'

class PaymentMethodTest < ActiveSupport::TestCase
  let(:pay) { PaymentMethod.new }
  let(:user) { users(:one) }

  it "audit tracking of token field" do
    pay.update!(token: "123", expires_at: Date.tomorrow, user: users(:one))
    pay.update!(token: "321")
    assert_equal 1, pay.audits.count
  end

  it "can't have empty token" do
    refute pay.valid?
    assert_match %r{can't be blank}i, pay.errors[:token].join
  end

  it "can't have empty expires_at" do
    refute pay.valid?
    assert_match %r{can't be blank}i, pay.errors[:expires_at].join
  end

  it "allows duplicate tokens" do
    pmt_two = PaymentMethod.create!(token: "123", expires_at: Date.tomorrow, user: users(:two))
    pmt_one = PaymentMethod.create!(token: "123", expires_at: Date.tomorrow, user: user)

    assert pmt_two.valid?
    assert pmt_one.valid?
  end
end
