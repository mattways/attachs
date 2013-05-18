
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
    task :clean, [:preset] do
      if ENV['NAME'].present?
        path = Rails.root.join('public', 'uploads', 'images', ENV['NAME'])
        ::FileUtils.rm_rf path if ::File.directory? path
      end
    end
  end

  namespace :s3 do
    namespace :buckets do
      desc 'Create buckets'
      task :create do
        config = YAML.load_file(Rails.root.join('config', 's3.yml'))
        config.each do |env, options|
          require 'aws-sdk'
          AWS.config access_key_id: options['access_key_id'], secret_access_key: options['secret_access_key']
          bucket = options['bucket']
          begin
            AWS::S3.new.buckets.create bucket
          rescue AWS::S3::Errors::InvalidAccessKeyId
            puts "Invalid credentials in #{env} environment."
            next
          rescue AWS::S3::Errors::BucketAlreadyExists
            puts "Bucket #{bucket} already exists."
            next
          rescue AWS::S3::Errors::BucketAlreadyOwnedByYou
            puts "You already own bucket #{bucket}."
            next
          end
          puts "Bucket #{bucket} created successfully."
        end
      end
    end
  end

end

