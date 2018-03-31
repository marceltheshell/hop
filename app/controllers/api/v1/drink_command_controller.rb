class Api::V1::DrinkCommandController < Api::SecuredController
  include RescueGatewayErrors

  # generic errors
  class Error < RuntimeError; end
  class UserNotFound < Error; end
  class PaymentError < Error; end
  class LineItemError < ActiveRecord::RecordInvalid; end

  # rescue from errors
  rescue_from UserNotFound,   with: :render_user_error
  rescue_from PaymentError,   with: :render_payment_error
  rescue_from LineItemError,  with: :render_line_item_error

  #
  # Display the customers payment details in "secured" format.
  #
  def customer
    user = find_user!
    raise PaymentError, 'not available' if user.payment_method.nil?
    raise PaymentError, 'has expired'   if user.payment_method.expired?

    render json: DrinkCommand::CustomerSerializer.new( user ), status: :ok
  end

  #
  # Process a charge against the customers credit card on file.
  #
  def charge
    render json: DrinkCommand::ChargeSerializer.new( do_charge! ), status: :created
  end

  #
  # Record a purchase (aka line-item)
  #
  def line_item
    render json: DrinkCommand::LineItemSerializer.new( do_line_item! ), status: :created
  end


  #
  #
  #
  private

  #
  # Customized error
  #
  def render_charge_failure( ex )
    render json: ErrorSerializer.new(
      code: 20400,
      errors: Hash( charge: [ex.description] )
    ), status: :not_acceptable
  end

  #
  # Customized error
  #
  def render_payment_error( ex )
    render json: ErrorSerializer.new(
      code: 20401,
      errors: Hash( payment: [ex.to_s] )
    ), status: :not_acceptable
  end

  #
  # Customized error
  #
  def render_user_error( ex )
    render json: ErrorSerializer.new(
      code: 20404,
      errors: Hash( session_token: ['missing or invalid'] )
    ), status: :not_found
  end

  #
  # Line item error
  #
  def render_line_item_error( ex )
    errors = ex.record.errors.full_messages
    render json: ErrorSerializer.new(
      code: 20402,
      errors: Hash( line_item: errors)
    ), status: :not_acceptable
  end

  #
  # Create a "line-item" from post body
  #
  def do_line_item!
    user    = ::User.find_by(rfid: rfid)
    LineItem.from_payload(user, line_item_params)
  rescue ActiveRecord::RecordInvalid => ex
    raise LineItemError, ex.record
  end

  #
  # Do the charge at the gateway
  #
  def do_charge!
    user    = ::User.find_by(rfid: rfid)
    gateway = ::BridgePayService.new( user )
    gateway.charge( charge_amount )
  end

  #
  # Find user by RFID
  #
  def find_user!
    ::User.find_by(rfid: rfid) || raise( UserNotFound )
  end

  #
  # Grab "rfid" from params
  #
  def rfid
    params[:session_token] || params[:rfid]
  end

  def charge_params
    @charge_params ||= params.require(:charge).permit(:amount_in_cents)
  end

  def charge_amount
    charge_params.dig(:amount_in_cents).to_i
  end

  def line_item_params
    @line_item_params ||= params.require(:line_item).to_unsafe_hash
      .except( :format, :controller, :action )
  end
end
