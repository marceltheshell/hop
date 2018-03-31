class Transaction::PurchaseSerializer < ApplicationSerializer
  attr_reader :purchase

  def initialize( purchase, options ={} )
    @purchase  = purchase
    @data_node = 'purchase'

    super(options)
  end

  def errors
    ErrorSerializer.new(
      code: 10008,
      errors: purchase.errors.as_json
    ).as_json
  end

  def errors?
    purchase.errors.any?
  end

  def data
    Hash(
    id:               purchase.id,
    purchased_at:     purchase.created_at,
    amount_in_cents:  purchase.amount_in_cents.to_i.abs,
    balance_in_cents: purchase.balance_in_cents,
    venue_id:         purchase.venue_id,
    qty:              purchase.qty,
    tap_id:           purchase.tap_id
    )
  end

end
