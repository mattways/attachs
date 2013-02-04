
namespace :uploads do
  namespace :presets do
    desc 'Clean preset'
    task :clean, [:preset] do |t, args|
      if args.preset
        path = Rails.root.join('public', 'uploads', 'images', args.preset)
        FileUtils.rm_rf path if ::File.directory? path
      end
    end
  end
end

