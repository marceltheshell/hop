require 'test_helper'

class QrCodeSmsJobTest < ActiveSupport::TestCase
  let(:one) { users(:one) }

  it "sends to Twilio" do
    resp = VCR.use_cassette("twilio/sms-success") do
      QrCodeSmsJob.perform_now( one.id )
    end

    assert resp.error_code.nil?
    assert_equal 'queued', resp.status
  end

  it "queues QrCodeSmsJob when successful" do
    assert_difference ->{ QrCodeSmsJob.jobs.size } do
      QrCodeJob.perform_now( one.id )
    end
  end

  it "returns false when user not found" do
    assert_equal false, QrCodeSmsJob.perform_now( "123" )
  end
end
