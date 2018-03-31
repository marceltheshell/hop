require 'test_helper'

class QrCodeJobTest < ActiveSupport::TestCase
  let(:one) { users(:one) }

  it "saves to s3" do
    resp  = QrCodeJob.perform_now( one.id )

    assert_equal Seahorse::Client::Response, resp.class
    assert resp.successful?
    refute resp.etag.blank?
  end

  it "queues QrCodeSmsJob when successful" do
    assert_difference ->{ QrCodeSmsJob.jobs.size } do
      QrCodeJob.perform_now( one.id )
    end
  end

  it "queues QrCodeJob when user.rfid is changed" do
    assert_difference ->{ QrCodeJob.jobs.size } do
      one.update!(rfid: "xyz12345")
    end
  end

  it "returns false when user not found" do
    assert_equal false, QrCodeJob.perform_now( "123" )
  end
end
