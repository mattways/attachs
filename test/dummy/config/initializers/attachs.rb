Attachs.configure do |config|

  config.prefix = 'uploads'
  config.fallback = 'missing.svg'
  config.convert_options = '-strip -quality 82'
  config.maximum_size = 5.megabytes

  config.interpolation :name do |record|
    record.name
  end

  config.after_process /^image\// do |path, attachment|
    width, height = dimensions(path)
    attachment.metadata.merge!(
      width: width,
      height: height,
      ratio: (height.to_d / width.to_d).to_f
    )
  end

end
