#
# Model to store inbound "line items"
# from DrinkCommand system. They will be processed
# after they are captured and stored locally.
#
class LineItem < ApplicationRecord
  belongs_to :user
  belongs_to :user_transaction, optional: true

  # default: :pending
  enum status: [:pending, :processed, :failed]

  # Specific accessors for values stored in the "payload" JSON field.
  store_accessor :payload, :line_item_id, :account_type, :account_name,
    :product_code, :volume_units, :money_units, :tap_id, :price_money_units,
    :price_volume_units, :note, :venue_id

  #
  # Validations
  #
  validates :dc_uuid, presence: true, uniqueness: true

  #
  # Callbacks
  #
  after_initialize do
    self.status ||= :pending
  end

  def line_item_at
    payload.dig('created_at')
  end

  def product?
    account_type.to_s.upcase == "PRODUCT"
  end

  #
  # Create corresponding purchase transaction,
  # and mark line-item 'processed'.
  #
  # Raises exception on validation error.
  #
  # Returns true when successful, false otherwise.
  #
  def process!
    return false          if processed? || user.nil?
    generate_transaction  if product?
    self.processed!       # marked processed
  rescue ActiveRecord::RecordInvalid
    self.failed!
    raise # re-raise original exception
  end

  #
  #
  #
  private

  #
  # Create a associated user_transaction for the
  # the line-item.
  #
  def generate_transaction
    transaction do
      trans = user.purchases.create!(
        amount_in_cents: money_units,
        qty: volume_units,
        venue_id: venue_id,
        tap_id: tap_id,
        description: account_name,
        created_at: line_item_at
      )
      update!(user_transaction: trans)
    end
  end

  #
  # ClassMethods
  #
  class << self
    #
    # Create & process from payload
    #
    def from_payload(user, payload)
      payload = payload.with_indifferent_access
      uuid    = payload.dig(:line_item_id)
      item    = find_by(dc_uuid: uuid) if uuid

      # return existing line item
      return item if item.present?

      # create new line item
      create!(user: user, dc_uuid: uuid, payload: payload).tap do |item|
        ::LineItemJob.perform_later( item.id )
      end
    end
  end
end
