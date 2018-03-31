module RescueGatewayErrors
  extend ActiveSupport::Concern

  included do
    rescue_from BridgePayService::ChargeFailure,   with: :render_charge_failure
    rescue_from BridgePayService::CreditFailure,   with: :render_credit_failure
    rescue_from BridgePayService::PaymentMissing,  with: :render_payment_required
    rescue_from BridgePayService::UserMissing,     with: :render_user_required
  end

  private

  #
  #
  #
  def render_credit_failure( ex )
    msg = ex.try(:description) || ex.to_s

    render json: ErrorSerializer.new(
      code: 10007,
      errors: Hash( credit: [msg] )
    ), status: :not_acceptable
  end

  #
  #
  #
  def render_charge_failure( ex )
    msg = ex.try(:description) || ex.to_s

    render json: ErrorSerializer.new(
      code: 10006,
      errors: Hash( charge: [msg] )
    ), status: :not_acceptable
  end

  #
  #
  #
  def render_payment_required( ex )
    render json: ErrorSerializer.new(
      code: 10011,
      errors: Hash( payment: ["details are missing"] )
    ), status: :not_acceptable
  end

  #
  #
  #
  def render_user_required( ex )
    render json: ErrorSerializer.new(
      code: 10004,
      errors: Hash( user: ["not found"] )
    ), status: :not_found
  end
end
