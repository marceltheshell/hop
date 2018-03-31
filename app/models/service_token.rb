#
# Service Token: auth token without expiration.
# Used for 3rd party integrations.
#
class ServiceToken < Knock::AuthToken
  
  private

  def verify_lifetime?
    false
  end
end
