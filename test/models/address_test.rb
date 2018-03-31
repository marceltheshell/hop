require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  let(:address) { Address.new }

  it "can't have an empty country field" do
    refute address.valid?
    assert_match %r{can't be blank}i, address.errors[:country].join
  end

  it "can't have empty user" do
    refute address.valid?
    assert_match %r{must exist}i, address.errors[:user].join
  end

  it "has default 'addres_type'" do
    assert_equal "default", address.address_type
  end
end
