require 'test_helper'

class StorageTest < ActiveSupport::TestCase

  setup do
    storage.upload image_path, 'test.jpg', 'image/jpeg'
  end

  teardown do
    storage.delete_all
  end

  test 'url' do
    configuration.base_url = 'https://cdn.dummy.com'
    assert_equal 'https://cdn.dummy.com/test.jpg', storage.url('test.jpg')

    configuration.base_url = nil
    assert_equal 'https://attachs-test.s3.amazonaws.com/test.jpg', storage.url('test.jpg')
  end

  test 'generate signed policy' do
    begins_at = Date.strptime('25/10/2017', '%d/%m/%Y')
    key = '1'
    policy, signature = storage.generate_signed_policy(begins_at, key)
    assert_equal(
      'eyJleHBpcmF0aW9uIjoiMjAxNy0xMC0yNVQwMDowNTowMFoiLCJjb25ka' \
      'XRpb25zIjpbeyJidWNrZXQiOiJhdHRhY2hzLXRlc3QifSxbImtleSIsIj' \
      'EiXSx7ImFjbCI6InByaXZhdGUifSxbIkNvbnRlbnQtVHlwZSIsImFwcGx' \
      'pY2F0aW9uL29jdGV0LXN0cmVhbSJdLFsiY29udGVudC1sZW5ndGgtcmFu' \
      'Z2UiLDAsNTI0Mjg4MF1dfQ==',
      policy
    )
    assert_equal '1CAKs9pgMRRqQbP2dPMSP+VKNnI=', signature
  end

  test 'upload' do
    response = fetch('test.jpg')
    assert_equal '200', response.code
    assert_equal 'image/jpeg', response.content_type
    assert_equal 'max-age=315360000, public', response.header['cache-control']
    assert_equal 'Thu, 31 Dec 2037 23:55:55 GMT', response.header['expires']
  end

  test 'exists' do
    assert storage.exists?('test.jpg')
    assert_not storage.exists?('other.jpg')
  end

  test 'fetch' do
    file = storage.fetch('test.jpg')
    assert console.identical?(image_path, file.path)
  end

  test 'copy' do
    storage.copy 'test.jpg', 'other.jpg'
    assert_path 'test.jpg'
    assert_path 'other.jpg'
  end

  test 'move' do
    storage.move 'test.jpg', 'other.jpg'
    assert_not_path 'test.jpg'
    assert_path 'other.jpg'
  end

end
