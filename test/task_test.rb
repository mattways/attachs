require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  include StorageHelper

  setup do
    Dummy::Application.load_tasks
  end

  test 'reprocess' do
    shop = Shop.new(logo: image)
    assert_raises do
      shop.logo.reprocess
    end

    shop.save
    shop.run_callbacks :commit
    shop.logo.paths.except(:original).each do |style, path|
      Attachs.storage.delete path
    end
    silence_stream(STDOUT) do
      Rake::Task['attachs:reprocess'].invoke
    end
    shop.reload
    shop.logo.paths.each do |style, path|
      assert_url shop.logo.url(style)
    end
    shop.logo.destroy
  end

  test 'fix missings' do
    shop = Shop.new(logo: image)
    assert_raises do
      shop.logo.fix_missings
    end

    shop.save
    shop.run_callbacks :commit
    %i(tiny small).each do |style|
      Attachs.storage.delete shop.logo.paths[style]
    end
    silence_stream(STDOUT) do
      Rake::Task['attachs:fix_missings'].invoke
    end
    shop.logo.paths.each do |style, path|
      assert_url shop.logo.url(style)
    end
    shop.logo.destroy
  end

  test 'clear' do
    shop1 = Shop.create(logo: image)
    shop1.run_callbacks :commit
    shop2 = Shop.create(logo: image)
    shop2.run_callbacks :commit
    shop2.delete
    silence_stream(STDOUT) do
      Rake::Task['attachs:clear'].invoke
    end
    shop1.logo.styles.each do |style, path|
      assert_url shop1.logo.url(style)
    end
    shop2.logo.styles.each do |style, path|
      assert_not_url shop2.logo.url(style)
    end
    shop1.logo.destroy
  end

end
