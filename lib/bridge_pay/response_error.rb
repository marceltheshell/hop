module BridgePay
  class ResponseError < RuntimeError
    attr_reader :response

    def initialize( resp )
      @response = resp
      super("Code: #{code} - #{message}")
    end

    def code
      response.ResponseCode
    end

    def description
      response.ResponseDescription
    end

    def message
      I18n.t("bridgepay.errors.#{code}", default: description)
    end
  end
end
