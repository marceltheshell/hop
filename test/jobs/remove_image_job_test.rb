require 'test_helper'

class RemoveImageJobTest < ActiveSupport::TestCase
  let(:user) { users(:one) }
  let(:identification) { identifications(:one) }
  let(:image_id) { SecureRandom.uuid }
  let(:old_image_id) { '68452323-B6FE-4152-AD13-6CF71F59CFE0' }

  it "is success" do
    resp = RemoveImageJob.perform_now( image_id )
    assert resp.successful?
    assert_equal Seahorse::Client::Response, resp.class
  end

  describe "for User" do
    before do
      user.update!(image_id: old_image_id)
    end

    it "changing users' image_id queues job to remove old image" do
      assert_difference ->{ RemoveImageJob.jobs.size } do
        user.update!(image_id: image_id)
      end
    end

    it "deleting user should queue remove job" do
      assert_difference ->{ RemoveImageJob.jobs.size } do
        user.destroy!
      end
    end
  end

  describe "for Identification" do
    before do
      identification.update!(image_id: old_image_id)
    end

    it "changing identifications' image_id queues job to remove old image" do
      assert_difference ->{ RemoveImageJob.jobs.size } do
        identification.update!(image_id: image_id)
      end
    end

    it "deleting identification queues remove job" do
      assert_difference ->{ RemoveImageJob.jobs.size } do
        identification.destroy!
      end
    end
  end
end
