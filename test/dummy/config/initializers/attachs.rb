Attachs.configure do |config|

  config.fallback = 'missing.svg'
  config.convert_options = '-strip -quality 82'
  config.maximum_size = 5.megabytes

  config.interpolation :name do |record|
    record.name
  end

end
