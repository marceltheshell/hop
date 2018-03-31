class Transaction::Refund < Transaction::Withdrawal
  
  def reference_number
    metadata.dig('ReferenceNumber')
  end

  def gateway_id
    metadata.dig('GatewayTransID')
  end

  def gateway_message
    metadata.dig('GatewayMessage')
  end
end
