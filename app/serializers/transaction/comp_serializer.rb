class Transaction::CompSerializer < ApplicationSerializer
  attr_reader :comp

  def initialize( comp, options ={} )
    @comp    = comp
    @data_node = 'comp'

    super(options)
  end

  def errors
    ErrorSerializer.new(
      code: 10010,
      errors: comp.errors.as_json
    ).as_json
  end

  def errors?
    comp.errors.any?
  end

  def data
    Hash(
      id:               comp.id,
      comp_at:          comp.created_at.try(:iso8601),
      amount_in_cents:  comp.amount_in_cents,
      balance_in_cents: comp.balance_in_cents,
      venue_id:         comp.venue_id,
      employee_id:      comp.employee_id
    )
  end
end
