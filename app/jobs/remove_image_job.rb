class RemoveImageJob < ApplicationJob
  sidekiq_options queue: 'storage'

  #
  #
  #
  def perform( image_id )
    ::StorageService.remove_image( image_id ) unless image_id.blank?
  end
end
