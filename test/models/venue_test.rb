require 'test_helper'

class VenueTest < ActiveSupport::TestCase
  it "venue.valid?" do
    venue = Venue.new(name: "LAS", city: "Las vegas")
      assert venue.valid?
      assert venue.errors.empty?
  end
end
