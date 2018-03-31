class QrCodeJob < ApplicationJob
  attr_reader :user
  sidekiq_options retry: 3

  #
  # Returns 'false' if user wasn't found.
  #
  def perform( user_id )
    with_db_connection do
      @user = User.find_by(id: user_id)
      @user ? create_and_save_code : false
    end
  end

  #
  #
  #
  private


  #
  # Note: Queue's job to send SMS with QR Code
  # after successful upload.
  #
  def create_and_save_code
    resp = ::StorageService.upload_qrcode(
      user.qr_code_name, generate_code)
    
    send_sms if resp.successful?
    resp
  end

  def send_sms
    ::QrCodeSmsJob.perform_later( user.id )
  end

  def generate_code
    ::BarcodeService.new( user.rfid ).to_qr.to_s
  end
end
