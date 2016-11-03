namespace :attachs do
  desc 'Reprocess all attachments.'
  task reprocess: :environment do
    Attachs.reprocess
  end

  desc 'Fixes missing styles.'
  task fix_missings: :environment do
    Attachs.fix_missings
  end

  desc 'Clears orphan files.'
  task clear: :environment do
    Attachs.clear
  end
end
