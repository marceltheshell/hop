module BridgePayHelper
  extend self

  #
  # Simulate a 'charge'
  #
  def charge_user(user, amount)
    VCR.use_cassette("bridgepay-charge") do
      ::BridgePayService.new( user ).charge( amount )
    end
  end
end
