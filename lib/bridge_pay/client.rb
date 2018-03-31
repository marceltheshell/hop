#
# Test Cards & Bank Accounts
#
# CVV numbers: AMEX 1234 or 1111, All Others 999 or 111
# PIN is usually the last four of the card number
#
# The following accounts will be accepted by the test server's validation
# mechanism and thus can be used for preliminary testing:
#
#   Visa          4111111111111111
#   MasterCard    5499740000000057
#   Discover      6011000991001201
#   Amex          371449635392376
#   Visa          4217651111111119
#   MasterCard    5149612222222229
#
#
module BridgePay
  class Client
    #
    # Check the API is up.
    #
    # Returns: Boolean
    #
    def ping
      do_request( BridgePay::Request.new(:ping).encoded ).success?
    end

    #
    # Refund specific amount to the customer credit card
    # using the their 'token' and gateway 'trans_id'.
    #
    # Note: Uses named arguments.
    #
    def refund( token:, trans_id:, amount: )
      raise ArgumentError if token.nil? || trans_id.nil? || amount.nil?

      req = BridgePay::Request.new(:refund, Hash(
        'MerchantCode'        => ::BridgePay.code,
        'MerchantAccountCode' => ::BridgePay.account,
        'Token'               => token,
        'Amount'              => amount,
        'TransactionType'     => 'refund',
        'ReferenceNumber'     => trans_id
      ))
     
      do_request( req.encoded )
    end

    #
    # Charge a specific amount to the customer credit card
    # using the their 'token'.
    #
    # Note: Uses named arguments.
    #
    def charge( token:, expires_at:, amount: )
      raise ArgumentError if token.nil? || expires_at.nil? || amount.nil?

      req = BridgePay::Request.new(:authorize, Hash(
        'MerchantCode'        => ::BridgePay.code,
        'MerchantAccountCode' => ::BridgePay.account,
        'Token'               => token,
        'Amount'              => amount,
        'ExpirationDate'      => parse_exp_date( expires_at ),
        'TransactionType'     => 'sale',
        'TransIndustryType'   => 'EC',
        'AcctType'            => 'R',
        'HolderType'          => 'P'
      ))
     
      do_request( req.encoded )
    end

    #
    # Credit a specific amount to the customer credit card
    # using the their 'token'.
    #
    # Note: Uses named arguments.
    #
    def credit( token:, expires_at:, amount: )
      raise ArgumentError if token.nil? || expires_at.nil? || amount.nil?

      req = BridgePay::Request.new(:credit, Hash(
        'MerchantCode'        => ::BridgePay.code,
        'MerchantAccountCode' => ::BridgePay.account,
        'Token'               => token,
        'Amount'              => amount,
        'ExpirationDate'      => parse_exp_date( expires_at ),
        'TransactionType'     => 'credit',
        'TransIndustryType'   => 'EC',
        'AcctType'            => 'R',
        'HolderType'          => 'P'
      ))
     
      do_request( req.encoded )
    end

    #
    #
    #
    private

    #
    # Parse expiration date
    #
    def parse_exp_date( day )
      Date.parse( day.to_s ).strftime("%m%y")      
    rescue ArgumentError
      nil
    end

    #
    # Preform generic request to BridgeComm API. 
    # Wrap response.
    #
    def do_request( data )
      resp = BridgePay.logger.tagged("SOAP") do
        client.call(:process_request, message: {requestMsg: data})
      end

      BridgePay::Response.new( resp )
    end

    #
    # SOAP client to talk with BridgeComm API.
    #
    def client
      @client ||= Savon.client(
        wsdl: BridgePay.wsdl_path,
        log: true,
        logger: BridgePay.logger
      )
    end
  end
end
