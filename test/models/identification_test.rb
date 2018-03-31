require 'test_helper'

class IdentificationTest < ActiveSupport::TestCase
  let(:identity) { Identification.new }

  it "can't have an empty expires_at field" do
    refute identity.valid?
    assert_match %r{can't be blank}i, identity.errors[:expires_at].join
  end

  it "can't have an expired identification" do
    expired_id = Identification.new(expires_at: Date.yesterday)
    
    refute expired_id.valid?
    assert_match %r{Expired identification}i, expired_id.errors[:expires_at].join
  end

end
