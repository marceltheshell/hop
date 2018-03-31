class Api::V1::Auth::BootController < Knock::AuthTokenController
  include RescueApiErrors

  #
  # Authenticate and render boot details.
  #
  def create
    render json: ::BootSerializer.new( auth_token ), status: :created
  end

  private

  #
  # Overloaded 'authenticate' method; can auth with email/password
  # or RFID.
  #
  def authenticate
    rfid_or_pin? ? authenticate_with_rfid_or_pin : authenticate_with_password
  end

  #
  # 'rfid' or 'pin' is present
  #
  def rfid_or_pin?
    auth_params[:rfid].present? || auth_params[:pin].present?
  end

  #
  # Auth with RFID or PIN; raise error if user wasn't found.
  #
  def authenticate_with_rfid_or_pin
    raise Knock::UserNotFound unless entity.present?
  end

  #
  # Auth with email/password; raise error if user wasn't found.
  # Bcrypt raises error when password is invalid or nil
  #
  def authenticate_with_password
    unless entity.present? && entity.authenticate( auth_params[:password] )
      raise Knock::UserNotFound
    end
  rescue BCrypt::Errors::InvalidHash
    raise Knock::UserNotFound
  end

  #
  # Build the 'auth token' for user
  #
  def auth_token
    entity.to_service_token
  end

  #
  # Found entity
  #
  def entity
    @entity ||= rfid_or_pin? ? entity_from_rfid_or_pin : entity_from_email
  end

  #
  # Find ServiceUser by email
  #
  def entity_from_email
    ServiceUser.where('email=?', auth_params[:email]).first
  end

  #
  # Find ServiceUser by RFID or PIN
  #
  def entity_from_rfid_or_pin
    ServiceUser.where('rfid=? OR pin=?', auth_params[:rfid], auth_params[:pin]).first
  end

  def auth_params
    params.require(:auth).permit :email, :password, :rfid, :pin
  end
end
