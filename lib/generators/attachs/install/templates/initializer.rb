Attachs.configure do |config|

  config.convert_options = '-strip -quality 82'
  config.cache_control_header = 'max-age=315360000, public'
  config.expires_header = Time.parse('31 Dec 2037 23:55:55 GMT').httpdate
  config.region = 'us-east-1'
  config.bucket = 'some-bucket'
  config.access_key_id = 'your-id'
  config.secret_access_key = 'your-pass'
  config.maximum_size_policy = 5.megabytes
  config.expiration_policy = 5.minutes

end
