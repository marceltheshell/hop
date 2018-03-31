#
# Send SMS/MMS messages
#
class SmsService
  Settings = Struct.new(:sid, :token, :number)

  #
  # ClassMethods
  #
  class << self

    #
    #
    #
    def deliver_mms( to:, message:, from: nil, url: nil )
      from ||= default_from

      client.account.messages.create({
        from: from, 
        to: normalize(to),
        body: message, 
        media_url: url
      }.compact)      
    end

    #
    # Normalize phone number: +1xxxxxxxxxx
    #
    def normalize( number )
      Phony.normalize(number.to_s, cc:'1')
        .gsub(/[^\d]/, '')
        .prepend("+")
    end

    #
    #
    #
    private

    def default_from
      @@default_from ||= settings.number
    end

    def client
      @@client ||= Twilio::REST::Client.new( 
        settings.sid, settings.token )
    end

    def settings
      @@settings ||= Settings.new(
        *Rails.application.secrets.twilio.to_s.split("|") )
    end
  end
end
