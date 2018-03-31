#
# Coming Soon!
#
class StorageService
  TTL          = 3600
  UPLOAD_PATH  = "uploads/%s.jpg".freeze
  HIRES_PATH   = "hires/%s.jpg".freeze
  LOWRES_PATH  = "lowres/%s.jpg".freeze
  BARCODE_PATH = "barcodes/%s.png".freeze
  QRCODE_PATH  = "qrcodes/%s.png".freeze

  #
  # ClassMethods
  #
  class << self
    #
    #
    #
    def prune_uploads
      bucket.objects(prefix: 'uploads/').each do |summary|
        filename = summary.key.split("/").last
        uuid     = filename.split(".").first

        if !User.exists?(image_id: uuid) && !Identification.exists?(image_id: uuid)
          puts "removing: #{uuid}"
          remove_image( uuid )
        end
      end
    end

    #
    # Move the uploaded image from 'uploads/*.jpg'
    # to the permanent path of 'hires/*.jpg'.
    #
    def move_image_upload( image_id )
      image_id   = image_id.to_s.upcase
      upload_key = UPLOAD_PATH % image_id
      hires_key  = HIRES_PATH % image_id
      upload     = bucket.object(upload_key)

      upload.copy_to(
        bucket.object(hires_key) ) if upload.exists?
    end

    #
    # Remove all versions of image.
    #
    def remove_image( image_id )
      image_id   = image_id.to_s.upcase
      upload_key = UPLOAD_PATH % image_id
      hires_key  = HIRES_PATH % image_id
      lowres_key = LOWRES_PATH % image_id

      client.delete_objects(
        bucket: aws.bucket,
        delete: {
          objects: [
            {key: upload_key},
            {key: hires_key},
            {key: lowres_key}
          ]
        }
      )
    end

    #
    # Remove old qr_codes
    #
    def remove_qrcode( qrcode_name )
      qrcode_name = qrcode_name.to_s.upcase
      qrcode_key  = QRCODE_PATH % qrcode_name

      client.delete_object({
        bucket: aws.bucket,
        key: qrcode_key, # required
        use_accelerate_endpoint: false,
      })
    end

    #
    # Upload barcode to S3
    #
    def upload_barcode(key, data)
      bucket.object(BARCODE_PATH % key).put(
        acl: 'bucket-owner-full-control',
        content_type: 'image/png',
        body: data
      )
    end

    #
    # Upload QR code to S3
    #
    def upload_qrcode(key, data)
      bucket.object( QRCODE_PATH % key ).put(
        acl: 'bucket-owner-full-control',
        content_type: 'image/png',
        body: data
      )
    end

    #
    # Signed URL for QR code image
    #
    def signed_qrcode_url( key, ttl=nil  )
      return if key.blank?
      signed_url( QRCODE_PATH % key, ttl )
    end

    #
    # Signed URL for barcode image
    #
    def signed_barcode_url( key, ttl=nil  )
      return if key.blank?
      signed_url( BARCODE_PATH % key, ttl )
    end

    #
    # Signed URL for lowres image
    #
    def signed_lowres_url( image_id, ttl=nil )
      return if image_id.blank?
      lowres_key = LOWRES_PATH % image_id
      signed_url( lowres_key, ttl )
    end

    #
    # 
    #
    def paths
      Hash(
        uploads: path_for(UPLOAD_PATH),
          hires: path_for(HIRES_PATH),
         lowres: path_for(LOWRES_PATH)
      )
    end

    #
    #
    #
    private

    def signed_url( key, ttl=TTL )
      bucket.object( key )
        .presigned_url(:get, expires_in: ttl)
    end

    def path_for( path )
      dest     = path % 'placeholder'
      dest_ext = File.extname(dest).gsub(".", "")

      Hash(
        pattern: path % ':uuid',
        prefix: File.dirname(dest) + "/",
        suffix: dest_ext,
        content_type: Mime::Type.lookup_by_extension(dest_ext).to_s
      )
    end

    def bucket
      @@bucket ||= Aws::S3::Bucket.new(aws.bucket, client: client)
    end

    def aws
      @@aws ||= AwsSettings.instance
    end

    def client
      @@client ||= Aws::S3::Client.new(
        region: aws.region,
        access_key_id: aws.id,
        secret_access_key: aws.secret,
        stub_responses: Rails.env.test?
      )
    end
  end
end
