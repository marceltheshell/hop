class Address < ApplicationRecord
  belongs_to :user, required: true

  validates :country, presence: true

  def address_type
    super || "default"
  end
end
