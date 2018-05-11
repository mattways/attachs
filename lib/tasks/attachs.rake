namespace :attachs do
  desc 'Clears orphan attachments.'
  task clear: :environment do
    Attachs.clear
  end
end
