Attachs.configure do |config|

  config.convert_options = '-strip -quality 82'
  config.region = 'us-east-1'
  config.bucket = "attachs.#{Rails.env}"

  config.add_interpolation :name do |record|
    record.name
  end

end
