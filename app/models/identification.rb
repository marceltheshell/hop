require 'digest/md5'

class Identification < ApplicationRecord
  include UploadedImage
  belongs_to :user, required: true

  validates :expires_at, presence: true
  validate  do
    errors.add(:expires_at, "Expired identification") if expired?
  end

  #
  # Fields encrypted at rest.
  #
  # Note: they are not search-able or
  # query-able via SQL.
  #
  store :encrypted_payload, accessors: [
    :issuer,
    :expires_at
  ], coder: Encryptor::Coder

  include ExpiresAtMethods

  private

  #
  # ClassMethods
  #
  class << self
    #
    # Code here
    #
  end
end
