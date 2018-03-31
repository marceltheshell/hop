class ServiceUser < User

  before_validation :set_pin
  validates :pin, presence: true, uniqueness: true, length: { is: 6, wrong_length: "PIN must be 6 digits long" }
  #
  # Generate a Auth token object
  #
  def to_service_token
    ServiceToken.new payload: { sub: self.id }
  end

  #
  #
  #
  private

  def setup_role
    self.role ||= 'service'
  end

  def set_pin
    self.pin ||= rand.to_s[2..7]
  end

end
