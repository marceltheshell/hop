class ApiController < ActionController::API
  include Knock::Authenticable
  include RescueApiErrors

  #
  # Custom route not found error.
  #
  def route_not_found
    render json: ErrorSerializer.new(
      code: 10001,
      errors: Hash( route: ["not found"] )
    ), status: :not_found
  end

  private

  #
  # Overload method from the Knock gem to
  # render custom error when 'not authorized'.
  #
  def unauthorized_entity(entity_name)
    render_unauthorized
  end
end
