class Api::SecuredController < ApiController
  before_action :authenticate_user, :require_service_role!

  def index
    render json: "secured"
  end

  private

  #
  # Require 'service' role for access
  #
  def require_service_role!
    unless current_user.try(:service?)
      raise ::Access::NotAuthorized
    end
  end  
end
