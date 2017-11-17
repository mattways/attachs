Attachs.configure do |config|

  config.convert_options = '-strip -quality 82'
  config.cache_control_header = 'max-age=315360000, public'
  config.expires_header = Time.parse('31 Dec 2037 23:55:55 GMT').httpdate
  config.region = 'us-east-1'
  config.bucket = 'attachs-test'
  config.access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.maximum_size_policy = 5.megabytes
  config.expiration_policy = 5.minutes

  config.interpolation :name do |record|
    record.name
  end

  config.after_process /^image\// do |file, attachment|
    width, height = read_dimensions(file.path)
    attachment.extras.merge!(
      width: width,
      height: height,
      ratio: (height.to_d / width.to_d).to_f
    )
  end

end
