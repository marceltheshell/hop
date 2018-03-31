require 'test_helper'

class EncryptorTest < ActiveSupport::TestCase

  it "generates key" do
    refute Encryptor.generate_key("my secret", SecureRandom.hex).blank?
  end

  it "encrypts" do
    assert Rails.application.secrets.encrypt_base64_key.present?
    assert Encryptor.encrypt("hello world").present?
  end

  it "decrypts" do
    assert Rails.application.secrets.encrypt_base64_key.present?
    data = Encryptor.encrypt("hello world")
    assert_equal "hello world", Encryptor.decrypt( data )
  end
end
