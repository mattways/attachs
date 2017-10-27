namespace :attachs do
  desc 'Clears orphan attachments.'
  task clear: :environment do
    Attachs.clear
  end

  desc 'Reprocess all attachments.'
  task reprocess: :environment do
    Attachs.reprocess
  end

  desc 'Fixes missing styles.'
  task fix_missings: :environment do
    Attachs.fix_missings
  end
end
