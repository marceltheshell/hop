require 'test_helper'

class BridgePayServiceTest < ActiveSupport::TestCase
  let(:user) { users(:two) }
  let(:gateway) { BridgePayService.new(user) }

  it "pings gateway" do
    assert VCR.use_cassette("bridgepay-ping"){ gateway.ping }
  end

  it "credit failure" do
    VCR.use_cassette("bridgepay-credit-error") do
      ex = assert_raises(BridgePay::ResponseError) do
        credit = gateway.credit( 0 )
      end

      assert_equal '10027', ex.code  
      assert_match /Invalid/i, ex.to_s
    end
  end

  it "issue credit" do
    VCR.use_cassette("bridgepay-credit") do
      credit = gateway.credit( 500 )

      assert credit.is_a?(Transaction::Credit)
      assert credit.reference_number.nil?
      assert_equal '223838304', credit.gateway_id
      assert_match /credit/i, credit.gateway_message
      assert_match /refund/i, credit.description
    end
  end

  it "refund error" do
    VCR.use_cassette("bridgepay-refund-error") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.refund( "123", 500 )
      end

      assert_equal '30029', ex.code  
      assert_match /Error/i, ex.to_s
    end
  end

  it "issue refund" do
    VCR.use_cassette("bridgepay-refund") do
      refund = gateway.refund( '221763504', 500 )

      assert refund.is_a?(Transaction::Refund)
      assert refund.reference_number.nil?
      assert_equal '222318604', refund.gateway_id
      assert_match /credit/i, refund.gateway_message
    end
  end

  it "denied error" do
    VCR.use_cassette("bridgepay-charge-denied") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 125 )
      end

      assert_equal '30032', ex.code  
      assert_match /Denied/i, ex.to_s
    end
  end

  it "internal error" do
    VCR.use_cassette("bridgepay-internal-error") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 14000 )
      end
      assert_equal '10052', ex.code  
      assert_match /Network/i, ex.to_s
    end
  end

  it "network error" do
    VCR.use_cassette("bridgepay-network-error") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 13000 )
      end
      assert_equal '30022', ex.code  
      assert_match /Network/i, ex.to_s
    end
  end

  it "insufficient funds error" do
    VCR.use_cassette("bridgepay-insufficient-funds") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 12000 )
      end
      assert_equal '30033', ex.code  
      assert_match /Insufficient/i, ex.to_s
    end
  end

  it "invalid security code error" do
    VCR.use_cassette("bridgepay-invalid-security-code") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 11000 )
      end
      assert_equal '30025', ex.code  
      assert_match /Security/i, ex.to_s
    end
  end

  it "pickup card error" do
    VCR.use_cassette("bridgepay-pickup-card") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 10000 )
      end
      assert_equal '30034', ex.code  
      assert_match /Hold/i, ex.to_s
    end
  end

  it "call for auth card error" do
    VCR.use_cassette("bridgepay-call-auth") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 9000 )
      end
      assert_equal '30072', ex.code  
      assert_match /Call/i, ex.to_s
    end
  end

  it "invalid card error" do
    VCR.use_cassette("bridgepay-invalid-card") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 7000 )
      end

      assert_equal '30023', ex.code  
      assert_match /Invalid/i, ex.to_s
    end
  end

  it "stolen card error" do
    VCR.use_cassette("bridgepay-stolen-card") do
      ex = assert_raises(BridgePay::ResponseError) do
        gateway.charge( 8000 )
      end
      
      assert_equal '30037', ex.code  
      assert_match /reported/i, ex.to_s
    end
  end

  it "success" do
    VCR.use_cassette("bridgepay-charge") do
      charge = nil
      
      assert_difference -> { Transaction::Charge.count } do
        charge = gateway.charge( 500 ) 
      end

      assert charge.is_a?(Transaction::Charge)
      assert charge.reference_number.nil?
      assert_equal '128375', charge.auth_code
      assert_equal 500, charge.amount_in_cents
      assert_equal '221763504', charge.gateway_id
      assert_match /credit/i, charge.description
    end
  end
end
