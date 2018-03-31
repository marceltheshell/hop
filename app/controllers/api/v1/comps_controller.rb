class Api::V1::CompsController < Api::SecuredController
include
  #
  # Creates a comp on customers credit card.
  #
  def create
    render json: ::Transaction::CompSerializer.new( do_comp! ), status: :created
  rescue ActiveRecord::RecordInvalid => ex
    render json: ::Transaction::CompSerializer.new( ex.record ), status: :not_acceptable
  end

  #
  #
  #
  private

  #
  # Perform the comp.
  #
  # returns Transaction::comp
  #
  def do_comp!
    # user = User.where('id=? OR rfid=?', user_param.to_i, user_param).first
    user = User.find(user_param)
    user.comps.create!(
    amount_in_cents: comp_amount,
    employee_id: comp_params.dig(:employee_id),
    venue_id: comp_params.dig(:venue_id),
    description: comp_params.dig(:description)
    )
  end

  #
  # Amount to comp
  #
  def comp_amount
    (comp_params.dig(:amount) || comp_params.dig(:amount_in_cents)).to_i
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
  def comp_params
    @comp_params ||= params.require(:comp).permit(
      :amount, :amount_in_cents, :employee_id, :venue_id, :description
    ).to_h
  end
end
