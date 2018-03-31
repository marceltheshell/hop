class RemoveQrCodeJob< ApplicationJob
  sidekiq_options queue: 'storage'

  #
  #
  #
  def perform( bygone_qrcode )
    ::StorageService.remove_qrcode( bygone_qrcode )
  end
end
