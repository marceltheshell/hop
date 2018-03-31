require 'test_helper'

class ErrorSerializerTest < ActiveSupport::TestCase

  it "default" do
    ErrorSerializer.new( {} ).to_json do |json|
      json = JSON.parse(json).dig('data')
      assert json.key?('message')
      assert json.key?('code')
      assert json.key?('errors')
    end
  end

  it "not record found" do
    error = Hash(record: ["Record for model id was not found"])
    not_record_found = Hash(errors: error, code:10004)

    ErrorSerializer.new( not_record_found ).to_json do |json|
      json = JSON.parse(json).dig('data')
      assert json.key?('code')
      assert json.key?('message')
      assert json.key?('errors')
      assert json.dig('errors').is_a?(Hash)
    end
  end

end
