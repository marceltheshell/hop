class AwsSettings < Struct.new(:id, :secret, :identity_pool_id, :identity_id, :region, :bucket)
  class IdentityNotFound < RuntimeError; end
  class PoolNotFound < RuntimeError; end

  def region
    super || 'us-east-1'    
  end

  def bucket
    super || 'hop-data'
  end

  def identity_id
    super || raise(IdentityNotFound)
  end

  def identity_pool_id
    super || raise(PoolNotFound)
  end

  def congnito
    @congnito ||= Aws::CognitoIdentity::Client.new(
      stub_responses: Rails.env.test?,
      region: region)
  end

  def congnito_identity_id
    congnito.get_id(
      identity_pool_id: identity_pool_id).identity_id
  end

  def congnito_credentials
    @congnito_credentials ||= congnito.get_credentials_for_identity(
      identity_id: identity_id).credentials
  end

  #
  # ClassMethods
  #
  class << self
    #
    # Singleton
    #
    def instance(&block)
      @@instance ||= new(*settings).tap do |aws| 
        yield aws if block_given?
      end
    end

    def settings
      Rails.application.secrets.aws.to_s.split("|")
    end
  end
end
