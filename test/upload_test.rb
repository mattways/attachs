require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  include StorageHelper

  test 'upload' do
    upload = Upload.create(file: image, record_type: 'Shop', record_attribute: 'logo')
    upload.run_callbacks :commit
    shop = Shop.create(logo: upload)
    shop.run_callbacks :commit
    assert_equal 5, shop.logo.paths.size
    shop.logo.styles.each do |style, geometry|
      assert_url shop.logo.url(style)
    end
    shop.logo.destroy

    shop = Shop.create(logo: upload.id)
    shop.run_callbacks :commit
    assert_equal 5, shop.logo.paths.size
    shop.logo.styles.each do |style, geometry|
      assert_url shop.logo.url(style)
    end
    shop.logo.destroy
    upload.file.destroy
  end

end
