class PaymentMethod < ApplicationRecord
  audited except: :encrypted_payload, on: [:update, :destroy] # audit trail

  belongs_to :user, required: true

  validates :token, presence: true#, uniqueness: true
  validates :expires_at, presence: true

  #
  # Fields encrypted at rest.
  #
  # Note: they are not search-able or
  # query-able via SQL.
  #
  store :encrypted_payload, accessors: [
    :card_type,
    :masked_number,
    :expires_at,
    :name_on_card
  ], coder: Encryptor::Coder

  #
  # Re-defines the 'expires_at'
  # accessors methods.
  #
  # NOTE: must be included AFTER the
  # 'store' attributes macro.
  #
  # FIXME: find better way to override the
  # accessors methods of a 'store attribute'.
  #
  include ExpiresAtMethods

  #
  # Convert to payment object
  #
  def to_payment
    Payment.new( token, expires_at )
  end
end
