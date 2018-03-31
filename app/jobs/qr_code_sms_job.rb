class QrCodeSmsJob < ApplicationJob
  attr_reader :user
  sidekiq_options retry: 3

  #
  # 
  #
  def perform( user_id )
    with_db_connection do
      @user = User.find_by(id: user_id)
      @user ? deliver_qr_code : false
    end
  end

  #
  #
  #
  private

  def deliver_qr_code
    return false if user.phone.blank?
    
    ::SmsService.deliver_mms(
      to: user.phone,
      message: I18n.t( 'barcode.message' ),
      url: media_url
    )
  end

  def media_url
    @media_url ||= ::StorageService
      .signed_qrcode_url( user.qr_code_name )
  end
end
