module BridgePay
  class Request

    def initialize( type, data = {} )
      @type = request_type( type )
      @data = data
    end

    #
    # Generate the 'encoded' payload for the BridgeComm API request.
    #
    def encoded
      msg = payload.to_xml(
        root: 'requestHeader', 
        skip_instruct: true, 
        skip_types: true,
        indent: 0
      )
      
      ::BridgePay.logger.tagged("REQUEST") {|logger| 
        logger.debug( ::BridgePay.filter_tags(msg) ) }
      
      Base64.strict_encode64( msg )
    end

    private

    #
    # Map request type to a BridgeComm request type.
    #
    def request_type( type )
      case type.to_sym
      when :ping
        '099'
      when :authorize, :credit
        '004'
      when :refund
        '012'
      when :capture
        '019'
      else
        raise ArgumentError, "Request type: #{type} is not implemented"
      end
    end

    #
    # BridgeComm request header
    #
    def payload
      Hash(
        'ClientIdentifier' => 'SOAP',
        'TransactionID'    => SecureRandom.uuid,
        'RequestType'      => @type,
        'User'             => ::BridgePay.username,
        'Password'         => ::BridgePay.password,
        'RequestDateTime'  => format_timestamp,
        'requestMessage'   => @data
      )      
    end

    #
    # BridgeComm formated dates:
    #   ie: YYYYMMDDHHMMSS
    #
    def format_timestamp( ts = Time.now.utc )
      ts.strftime("%Y%m%d%H%M%S")
    end
  end
end
