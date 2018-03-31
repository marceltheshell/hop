module DrinkCommandHelper
  extend self
  
  #
  # Generate sample LineItem
  #
  def generate_line_item( amount: -175, type: "PRODUCT" )
    ActiveSupport::HashWithIndifferentAccess.new(
      line_item_id: SecureRandom.uuid,
      session_uuid: '58d2fa8c55098',
      created_at: '2017-05-02 10:37:21 (-0700)',
      account_type: type,
      account_name: 'Blue Moon',
      product_code: 'blue_moon',
      volume_units: 70,
      money_units: amount,
      tap_id: "1b",
      price_money_units: 25, 
      price_volume_units: 10,
      note: nil,
      venue_id: "123"
    )
  end
end
