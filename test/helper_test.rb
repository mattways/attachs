require 'test_helper'

class HelperTest < ActionView::TestCase
  include StorageHelper

  test 'fields for' do
    product = Product.create(pictures: [image])
    product.run_callbacks :commit
    product.pictures.build

    html = form_for(product, url: 'test') do |f|
      f.fields_for(:pictures) do |ff|
        ff.file_field(:value) +
        ff.number_field(:position)
      end
    end

    assert html.include?('[pictures_attributes][0][id]')
    assert html.include?('[pictures_attributes][0][value]')
    assert html.include?('[pictures_attributes][0][position]')
    assert html.exclude?('[pictures_attributes][1][id]')
    assert html.include?('[pictures_attributes][1][value]')
    assert html.include?('[pictures_attributes][1][position]')

    product.pictures.destroy
  end

end
