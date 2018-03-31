class AuthSerializer < ApplicationSerializer
  attr_reader :auth_token, :user

  def initialize( auth_token, user, options={} )
    @auth_token  = auth_token
    @user        = user

    super( options )
  end

  def data
    Hash(
      jwt: auth_token.token,
      user: UserSerializer.new( user, nested: false).as_json
    )
  end

  def errors
    ErrorSerializer.new(
      code: 10002,
      errors: Hash( user: ["has errors"] )
    ).as_json
  end

  def errors?
    user.errors.any?
  end
end
