class MoveImageJob < ApplicationJob
  sidekiq_options queue: 'storage'

  #
  # 
  #
  def perform( image_id )
    ::StorageService.move_image_upload( image_id ) unless image_id.blank?
  end
end
