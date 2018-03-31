require 'test_helper'

class SmsServiceTest < ActiveSupport::TestCase
  let(:service) { SmsService }
  let(:mobile) { "+17605551212" }
  let(:body) { "This is test" }
  let(:media) { 'http://www.beer100.com/images/beermug.jpg' }

  it "delivers a sms" do
    VCR.use_cassette("twilio/sms-success") do
      assert service.deliver_mms(
        to: mobile,
        message: body
      )
    end
  end

  it "delivers a mms" do
    VCR.use_cassette("twilio/mms-success") do
      assert service.deliver_mms(
        to: mobile,
        message: body,
        url: media
      )
    end
  end

  it "invalid twilio number" do
    VCR.use_cassette("twilio/from-failure") do
      ex = assert_raises(Twilio::REST::RequestError) do 
        service.deliver_mms(
          from: '+15005550001',
          to: mobile,
          message: body
        )
      end
      assert_match /not a valid/i, ex.message
    end
  end

  it "invalid mobile number" do
    VCR.use_cassette("twilio/to-invalid") do
      ex = assert_raises(Twilio::REST::RequestError) do 
        service.deliver_mms(
          to: '5005550001',
          message: body
        )
      end
      assert_match /not a valid/i, ex.message
    end
  end
end
