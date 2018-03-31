class Api::V1::PurchasesController < Api::SecuredController

  #
  # Creates a purchase on customers credit card.
  #
  def create
    render json: ::Transaction::PurchaseSerializer.new( do_purchase ), status: :created
  rescue ActiveRecord::RecordInvalid => ex
    render json: ::Transaction::PurchaseSerializer.new( ex.record ), status: :bad_request
  end

  #
  # need to rescue error created by balance going below zero
  private

  #
  # Perform the purchase.
  #
  # Note: raises ActiveRecord::RecordInvalid for validation errors.
  #
  # returns Transaction::Purchase
  #
  def do_purchase
    user.purchases.create!(
      amount_in_cents: purchase_amount,
      employee_id: purchase_params.dig(:employee_id),
      qty: purchase_params.dig(:qty).to_i,
      venue_id: purchase_params.dig(:venue_id),
      tap_id: purchase_params.dig(:tap_id),
      description: purchase_params.dig(:description)
    )
  end

  def purchase_amount
    (purchase_params.dig(:amount_in_cents) || purchase_params.dig(:amount)).to_i
  end

  #
  # Note: raises ActiveRecord::RecordNotFound if user not found
  #
  def user
    @user ||= User.find(
      params[:user_id] ) # needs to raise exception if user not found
  end

  #
  # Safe params from the intertube
  #
  def purchase_params
    @purchase_params ||= params.require(:purchase).permit(
      :amount, :amount_in_cents, :employee_id, :qty,
      :venue_id, :tap_id, :description
    ).to_h
  end
end
