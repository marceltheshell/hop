class Api::V1::CreditsController < Api::SecuredController
  include RescueGatewayErrors

  #
  # Creates a credit on customers credit card.
  #
  def create
    render json: ::Transaction::CreditSerializer.new( do_credit! ), status: :created
  end

  #
  #
  #
  private

  #
  # Perform the credit.
  #
  # returns Transaction::credit
  #
  def do_credit!
    # user = User.where('id=? OR rfid=?', user_param.to_i, user_param).first
    user = User.find_by(id: user_param)
    BridgePayService.new( user ).credit( credit_amount )
  end

  #
  # Amount to credit
  #
  def credit_amount
    (credit_params.dig(:amount) || credit_params.dig(:amount_in_cents)).to_i
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
  def credit_params
    @credit_params ||= params.require(:credit).permit(
      :amount, :amount_in_cents
    ).to_h
  end
end
