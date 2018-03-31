require 'test_helper'

class RemoveQrCodeJobTest < ActiveSupport::TestCase
  let(:one) { users(:one) }

  it "saves to s3" do
    resp  = RemoveQrCodeJob.perform_now( one.id )
    assert_equal Seahorse::Client::Response, resp.class
    assert resp.successful?
    refute resp.delete_marker
  end

  it "queues RemoveQrCodeJob when an existing RFID ('efg12345') gets replaced " do
    assert_difference ->{ RemoveQrCodeJob.jobs.size } do
      one.update!(rfid: "xyz12345")
    end
  end

  it "does not enqueue process when rfid_was = nil" do
    assert_no_difference ->{ RemoveQrCodeJob.jobs.size } do
      user = User.create!(email: "no_remove_qr_job@br.us", rfid: "12345XYW")
    end
  end
end
