class Transaction::ChargeSerializer < ApplicationSerializer
  attr_reader :charge

  def initialize( charge, options ={} )
    @charge    = charge
    @data_node = 'charge'

    super(options)
  end

  def errors
    ErrorSerializer.new(
      code: 10006,
      errors: charge.errors.as_json
    ).as_json
  end

  def errors?
    charge.errors.any?
  end

  def data
    Hash(
      id:               charge.id,
      charge_at:        charge.created_at.try(:iso8601),
      amount_in_cents:  charge.amount_in_cents,
      balance_in_cents: charge.balance_in_cents,
      metadata:         charge.metadata
    )
  end
end
