require 'test_helper'

class CameraTest < ActiveSupport::TestCase
  let(:venue) { Venue.create!(name: "SFO", city:"San Francisco") }

  it "Camera.valid?" do
    Camera.new(venue: venue).tap do |camera|
      assert camera.valid?
      assert camera.errors.empty?
    end
  end

  it "has name" do
    Camera.new(venue: venue, name: "Camera #1").tap do |camera|
      assert_equal "Camera #1", camera.name
    end
  end
end
