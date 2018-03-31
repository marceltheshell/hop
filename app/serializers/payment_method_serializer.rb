class PaymentMethodSerializer < ApplicationSerializer
  attr_reader :payment_method

  def initialize( payment_method, options ={} )
    @payment_method = payment_method

    super(options)
  end

  def data
    Hash(
      id: payment_method.id,
      token: payment_method.token,
      card_type: payment_method.card_type,
      masked_number: payment_method.masked_number,
      expires_at: payment_method.expires_at.try(:iso8601),
    )
  end
end
