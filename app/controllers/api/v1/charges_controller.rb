class Api::V1::ChargesController < Api::SecuredController
  include RescueGatewayErrors

  #
  # Creates a charge on customers credit card.
  #
  def create
    render json: ::Transaction::ChargeSerializer.new( do_charge! ), status: :created
  end

  #
  #
  #
  private

  #
  # Perform the charge.
  #
  # returns Transaction::Charge
  #
  def do_charge!
    # user = User.where('id=? OR rfid=?', user_param.to_i, user_param).first
    user = User.find_by(id: user_param)
    BridgePayService.new( user, payment ).charge( charge_amount )
  end

  #
  # Create payment object for the transaction.
  #
  def payment
    if pay = charge_params.dig('payment_method')
      ::Payment.new( pay.dig('gateway_token'), pay.dig('expires_at') )
    end
  end

  #
  # Amount to charge
  #
  def charge_amount
    (charge_params.dig(:amount) || charge_params.dig(:amount_in_cents)).to_i
  end

  #
  # Find user by this param
  #
  def user_param
    params[:user_id]
  end

  #
  # Safe params from the intertube
  #
  def charge_params
    @charge_params ||= params.require(:charge).permit(
      :amount, :amount_in_cents,
      payment_method: [:token, :expires_at]
    ).to_h
  end
end
