require 'test_helper'

class StorageServiceTest < ActiveSupport::TestCase
  let(:service) { StorageService }

  it "#move_image_upload is successful" do
    assert service.move_image_upload( "123 ").successful?
  end

  it "#remove_image is successful" do
    assert service.remove_image( "123 ").successful?
  end

  it "#upload_barcode is successful" do
    assert service.upload_barcode( "123", "123").successful?
  end

  it "#upload_qrcode is successful" do
    assert service.upload_qrcode( "123", "123").successful?
  end

  it "#paths" do
    service.paths.tap do |p|
      assert p.key?(:uploads)
      assert p.key?(:hires)
      assert p.key?(:lowres)
    end
  end
end
