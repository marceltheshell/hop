#
# Payment object to represent a credit card "token" and
# expiration date.
#
class Payment < Struct.new(:token, :expires_at)
  def valid?
    token.present? && expires_at.present?
  end
end
