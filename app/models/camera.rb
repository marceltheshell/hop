class Camera < ApplicationRecord
  # Creating scope :tap. Overwriting existing method Camera.tap,
  # therefore calling the style: "beer_tap"
  enum style: [ :beer_tap, :podium ]
  
  belongs_to :venue
end
