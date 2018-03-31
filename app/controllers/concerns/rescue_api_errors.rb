module RescueApiErrors
  extend ActiveSupport::Concern

  included do
    rescue_from ::ActiveRecord::RecordNotFound,       with: :render_not_found
    rescue_from ::Knock::UserNotFound,                with: :render_unauthorized
    rescue_from ::Access::NotAuthorized,              with: :render_unauthorized
    rescue_from ::ActionController::ParameterMissing, with: :render_missing_params
  end

  private

  #
  # Render 'not authorized' error
  #
  def render_unauthorized
    error_message = Hash(access: ["Unauthorized"])
    errors        = Hash(code: 10005, errors: error_message)

    render json: ErrorSerializer.new(errors), status: :unauthorized
  end


  #
  # Render generic 'not found' error.
  #
  def render_not_found( e )
    render json: ErrorSerializer.new(
      code: 10004,
      errors: Hash( record: ["not found"] )
    ), status: :not_found
  end


  #
  # Render 'missing params' error.
  #
  def render_missing_params
    render json: ErrorSerializer.new(
      code: 10013,
      errors: Hash( record: ["Missing Params"] )
    ), status: :unprocessable_entity
  end

end
