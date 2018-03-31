class Transaction::CreditSerializer < ApplicationSerializer
  attr_reader :credit

  def initialize( credit, options ={} )
    @credit    = credit
    @data_node = 'credit'

    super(options)
  end

  def errors
    ErrorSerializer.new(
    code: 10007,
    errors: credit.errors.as_json
    ).as_json
  end

  def errors?
    credit.errors.any?
  end

  def data
    Hash(
    id:               credit.id,
    credit_at:        credit.created_at.try(:iso8601),
    amount_in_cents:  credit.amount_in_cents.to_i.abs,
    balance_in_cents: credit.balance_in_cents,
    metadata:         credit.metadata
    )
  end
end
