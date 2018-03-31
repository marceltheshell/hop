class Api::V1::Auth::UserTokenController < Knock::AuthTokenController
  include RescueApiErrors
  #
  #
  #
  def create
    render json: ::AuthSerializer.new( auth_token, entity ), status: :created
  end

  private

  def entity_class
    ::User
  end
end
