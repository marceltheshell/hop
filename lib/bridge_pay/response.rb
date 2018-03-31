module BridgePay
  class Response
    attr_reader :body, :header, :code

    SUCCESS = '00000'    

    def initialize(response)      
      doc  = parse( decode( result(response) ) )  # parse response from encoded message
      root = doc.values.first                     # get root node

      @body   = root.responseMessage              # extract body data
      @header = root.except(:responseMessage)     # extract header data
      @code   = header.ResponseCode               # extract request code

      # raise error unless request was success
      raise BridgePay::ResponseError.new( root ) unless success?
    end

    def success?
      code == SUCCESS
    end

    #
    #
    #
    private

    #
    # Extract encoded result message
    #
    def result( response )
      response.body
        .dig(:process_request_response, :process_request_result) 
    end

    #
    # Decode the message
    #
    def decode( data )
      Base64.decode64( data ).tap do |decoded|
        ::BridgePay.logger.tagged("RESPONSE") {|logger| 
          logger.debug( ::BridgePay.filter_tags(decoded) ) }
      end
    end

    #
    # Parse XML response into Hashie::Mash
    #
    def parse( data )
      Hashie::Mash.new( 
        Hash.from_xml( data ) )
    end
  end
end
