class Transaction::Charge < Transaction::Deposit
  after_create :send_charge_email

  def auth_code
    metadata.dig('AuthorizationCode')
  end

  def reference_number
    metadata.dig('ReferenceNumber')
  end

  def gateway_id
    metadata.dig('GatewayTransID')
  end

  def gateway_message
    metadata.dig('GatewayMessage')
  end

  #
  #
  #
  private

  def send_charge_email
    UserNotifierMailer.delay.charge_email(self.id)
  end
end
