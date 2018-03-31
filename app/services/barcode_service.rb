require 'barby'
require 'barby/barcode/pdf_417'
require 'barby/outputter/png_outputter'

#
# Wrapper class for generating barcodes.
#
class BarcodeService
  attr_reader :message

  def initialize( message )
    @message = message
  end

  #
  # Generate QR code for message
  #
  def to_qr( size=120 )
    RQRCode::QRCode.new( message )
    .as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: size,
      border_modules: 2,
      module_px_size: 4
    )      
  end

  #
  # Generate PDF417 code for message
  #
  def to_pdf_417( size=2 )
    Barby::Pdf417.new( message )
    .to_image(ydim: size, xdim: size, margin: 2)
  end
end
