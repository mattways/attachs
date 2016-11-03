module StorageHelper

  private

  def build_upload_file(path, content_type)
    fixtures_path = File.expand_path('../../fixtures', __FILE__)
    filename = File.basename(path)
    extension = File.extname(path)
    tempfile = Tempfile.new([filename, extension])
    FileUtils.copy_file File.join(fixtures_path, path), tempfile.path
    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end

  %i(file small_file big_file).each do |name|
    define_method name do
      build_upload_file "#{name}.txt", 'text/plain'
    end
  end

  %i(image small_image big_image).each do |name|
    define_method name do
      build_upload_file "#{name}.jpg", 'image/jpeg'
    end
  end

  def assert_url(url)
    response = get(url)
    assert_equal '200', response.code
  end

  def assert_not_url(url)
    response = get(url)
    assert_equal '403', response.code
  end

  def assert_url_content_type(value, url)
    response = get(url)
    assert_equal value, response.content_type
  end

  def assert_url_dimensions(value, url)
    response = get(url)
    tmp = Tempfile.new
    tmp.binmode
    tmp.write response.body
    tmp.rewind
    tmp.close
    dimensions = `gm identify -format %wx%h '#{tmp.path}'`.strip
    assert_equal value, dimensions
  end

  def get(url)
    if url.starts_with?('//')
      url.prepend 'http:'
    end
    Net::HTTP.get_response URI.parse(url)
  end

  def humanize_size(size)
    ActiveSupport::NumberHelper.number_to_human_size size
  end

end
