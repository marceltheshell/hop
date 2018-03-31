require 'test_helper'

class UploadedImageTest < ActiveSupport::TestCase
  let(:model) { users(:one) }
  let(:uuid) { SecureRandom.uuid }

  describe "#after_save" do
    it "change value queues MoveJob" do
      assert_difference ->{ MoveImageJob.jobs.size } do
        model.update!(image_id: uuid)
      end
    end

    it "change value queues RemoveImageJob" do
      assert_difference ->{ RemoveImageJob.jobs.size } do
        model.update!(image_id: uuid)
      end
    end

    it "case change does not queue jobs" do
      assert_difference ->{ MoveImageJob.jobs.size } do
        model.update!(image_id: uuid.downcase)
      end

      assert_no_difference ->{ MoveImageJob.jobs.size } do
        model.update!(image_id: uuid.upcase)
      end
    end
  end
end
