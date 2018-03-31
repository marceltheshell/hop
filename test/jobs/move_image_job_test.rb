require 'test_helper'

class MoveImageJobTest < ActiveSupport::TestCase
  let(:user) { users(:one) }
  let(:identification) { identifications(:one) }
  let(:image_id) { SecureRandom.uuid.upcase }

  it "is success" do
    resp = MoveImageJob.perform_now( image_id )
    assert resp.successful?
    assert_equal Seahorse::Client::Response, resp.class
  end

  describe "for User" do
    it "changing users' image_id queues move job" do
      assert_difference ->{ MoveImageJob.jobs.size } do
        user.update!(image_id: image_id)
      end
    end
  end

  describe "for Identification" do
    it "changing identifications' image_id queues move job" do
      assert_difference ->{ MoveImageJob.jobs.size } do
        identification.update!(image_id: image_id)
      end
    end
  end
end
