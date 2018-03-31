require 'test_helper'

class BarcodeServiceTest < ActiveSupport::TestCase
  def behaves_like_png( image )
    assert image.height > 0
    assert image.width > 0
  end

  it "creates a QR Code" do
    behaves_like_png BarcodeService.new( "http://github.com/" ).to_qr
    behaves_like_png BarcodeService.new( "123456ABC" ).to_qr
    behaves_like_png BarcodeService.new( "http://www.bluerocket.us/" ).to_qr
  end

  it "creates pdf417 format" do
    behaves_like_png BarcodeService.new( 'de86b8e7-dd9f-4e11-a208-9febf9e61bb1' ).to_pdf_417
  end
end
