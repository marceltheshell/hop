require 'bridge_pay/response_error'
require 'bridge_pay/response'
require 'bridge_pay/request'
require 'bridge_pay/client'

module BridgePay
  extend self
  delegate :username, :password, :code, :account, to: :secrets

  FILTER_TAGS = ["User", "Password", "MerchantCode", 
    "MerchantAccountCode"].freeze

  #
  #
  #
  def logger
    @logger ||= ActiveSupport::TaggedLogging.new( Logger.new(STDOUT) ).tap do |logger|
      logger.level = Rails.logger.level
      logger.clear_tags!
      logger.push_tags(["BridgePay API"])
    end
  end

  #
  #
  #
  def wsdl_path
    base = File.join(Rails.root, 'lib', 'bridge_pay', 'wsdl')

    # Rails.env.production? ? 
    #   File.join(base, 'bridgepay.wsdl') :
    #   File.join(base, 'bridgepay-test.wsdl')
    
    File.join(base, 'bridgepay-test.wsdl')
  end

  #
  # Redact secret tags
  #
  def filter_tags( buffer )
    buffer.dup.tap do |data|
      FILTER_TAGS.each do |tag|
        data.gsub!(%r{<#{tag}>(.*)</#{tag}>}){|m| m.gsub!($1, '[FILTERED]')}
      end
    end
  end

  #
  #
  #
  private

  #
  #
  #
  def secrets
    @secrets ||= begin
      pairs = [:username, :password, :code, :account].zip(
        Rails.application.secrets.bridge_pay.split('|') )
      Hashie::Mash.new( Hash[pairs] )
    end
  end
end
