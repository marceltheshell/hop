require 'bridge_pay'

#
# Wrapper class for BridgeComm interface. Will be used
# to add custom logic around transactions.
#
class BridgePayService
  attr_reader :user, :payment

  #
  # error classes
  #
  class Error < RuntimeError; end
  class UserMissing < Error; end
  class PaymentMissing < Error; end
  class Failure < BridgePay::ResponseError; end
  class ChargeFailure < Failure; end
  class RefundFailure < Failure; end
  class CreditFailure < Failure; end

  #
  #
  #
  def initialize( user, payment=nil )
    @user    = user
    @payment = payment

    validate_required!
  end

  #
  # Check the API is up.
  #
  def ping
    client.ping
  end

  #
  # Credit a specific amount to the customer credit card
  # using the their 'token'.
  #
  def credit( amount_in_cents )
    resp = client.credit(
      token:      payment.token,
      expires_at: payment.expires_at,
      amount:     amount_in_cents.to_i.abs
    ).body
    user.credits.create!(
      amount_in_cents: amount_in_cents,
      description: I18n.t('transactions.credit'),
      metadata: resp.as_json
    )
  rescue BridgePay::ResponseError => ex
    raise CreditFailure.new( ex.response )
  end

  #
  # Charge a specific amount to the customer credit card
  # using the their 'token'.
  #
  def charge( amount_in_cents )
    resp = client.charge(
      token:      payment.token,
      expires_at: payment.expires_at,
      amount:     amount_in_cents.to_i.abs
    ).body

    user.charges.create!(
      amount_in_cents: resp.AuthorizedAmount.to_i,
      description: I18n.t('transactions.charge'),
      metadata: resp.as_json
    )
  rescue BridgePay::ResponseError => ex
    raise ChargeFailure.new( ex.response )
  end

  #
  # Issue refund to the customer credit card
  # using the their 'token' and 'trans_id'.
  #
  def refund( trans_id, amount_in_cents )
    resp = client.refund(
      token:    payment.token,
      trans_id: trans_id,
      amount:   amount_in_cents.to_i.abs
    ).body

    user.refunds.create!(
      amount_in_cents: amount_in_cents,
      description: "Refund value",
      metadata: resp.as_json
    )
  rescue BridgePay::ResponseError => ex
    raise RefundFailure.new( ex.response )
  end

  #
  #
  #
  private

  #
  # Try to load payment from users' account (PaymentMethod)
  #
  def payment
    @payment ||= user.try(:payment_method).try(:to_payment)
  end

  #
  # Raise errors if missing critical objects
  #
  def validate_required!
    raise UserMissing     if user.nil?
    raise PaymentMissing  if payment.nil? || !payment.valid?
  end

  #
  #
  #
  def client
    @client ||= ::BridgePay::Client.new
  end
end
