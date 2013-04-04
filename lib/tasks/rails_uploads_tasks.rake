
namespace :uploads do
  task :migrate do
    files = Rails.root.join('public', 'uploads', 'files')
    images = Rails.root.join('public', 'uploads', 'images', 'original')
    ::FileUtils.mkdir_p files
    ::FileUtils.mkdir_p images
    Dir.glob(::File.join(Rails.root.join('public', 'uploads'), '', '*.*')) do |source|
      filename = ::File.basename(source)
      if filename =~ /-/
        ::FileUtils.rm source
      elsif filename =~ /\.(jpg|png|gif)$/
        ::FileUtils.mv source, ::File.join(images, filename)
      else filename =~ /\.!(htm|html|ico)$/
        ::FileUtils.mv source, ::File.join(files, filename)
      end
    end
  end

  namespace :presets do
    desc 'Clean preset'
    task :clean, [:preset] do |t, args|
      if args.preset
        path = Rails.root.join('public', 'uploads', 'images', args.preset)
        ::FileUtils.rm_rf path if ::File.directory? path
      end
    end
  end
end

