require 'test_helper'

class Api::V1::QrCodesTest < ActionDispatch::IntegrationTest
  let(:user) { users(:two) }

  describe "/qrcodes/deliver" do
    it "queues sms job" do
      assert_difference ->{ QrCodeSmsJob.jobs.size } do
        post api_v1_users_qrcode_deliver_path( user.id ), headers: authenticated_header
      end      

      assert_response :success
    end
  end
end
