module UploadedImage
  extend ActiveSupport::Concern

  included do
    after_save :move_image
    after_destroy :remove_image
  end

  #
  # Normalize 'image_id' to uppercase
  #
  def image_id
    read_attribute(:image_id).try(:upcase)
  end

  private

  #
  # Queue job to remove S3 uploads
  #
  def remove_image
    RemoveImageJob.perform_later( image_id )
  end

  #
  # Queue job to move uploaded image into 'hires' bucket @ s3
  #
  def move_image
    if image_id_changed?
      MoveImageJob.perform_later( image_id )
      RemoveImageJob.perform_later( image_id_was )
    end
  end  

  #
  # Detect case-insensitive change
  #
  def image_id_changed?
    image_id.try(:upcase) != image_id_was.try(:upcase)
  end
end
