class Encryptor
  #
  # Coder module used for serializing a
  # attribute store on a ActiveRecord model.
  #
  module Coder
    extend self 

    def load(value)
      return if value.blank?

      Marshal.load(
        Encryptor.decrypt(value))
    end

    def dump(value)
      Encryptor.encrypt(
        Marshal.dump(value))
    end    
  end

  #
  # ClassMethods
  #
  class << self
    def encrypt( plaintext )
      encryptor.encrypt_and_sign( plaintext )
    end

    def decrypt( encrypted_data )
      encryptor.decrypt_and_verify( encrypted_data )
    end

    def generate_key(passphrase, salt)
      Base64.strict_encode64( 
        ActiveSupport::KeyGenerator.new( passphrase ).generate_key( salt ) )
    end

    #
    #
    #
    private

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new( 
        Base64.strict_decode64( Rails.application.secrets.encrypt_base64_key ) )
    end
  end
end
