class Api::V1::QrCodesController < Api::SecuredController
  #
  # Queue job to deliver QR code via MMS.
  #
  def deliver
    QrCodeSmsJob.perform_later( params[:user_id] )
    render json: StatusSerializer.new(:queued), status: :ok
  end
end
