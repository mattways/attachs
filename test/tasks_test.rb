require 'test_helper'
require 'rake'

class TasksTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  test 'refresh all styles' do
    Medium.create(attach: image_upload)
    original_small_time = small_time
    original_big_time = big_time
    ENV['CLASS'] = 'medium'
    ENV['ATTACHMENT'] = 'attach'
    sleep 1
    Rake::Task['attachs:refresh:all'].invoke
    assert File.file?(image_path(:small))
    assert File.file?(image_path(:big))
    assert_not_equal original_small_time, small_time
    assert_not_equal original_big_time, big_time
  end

  test 'refersh missing styles' do
    Medium.create(attach: image_upload)
    original_big_time = big_time
    original_small_time = small_time
    File.delete image_path(:small)
    ENV['CLASS'] = 'medium'
    ENV['ATTACHMENT'] = 'attach'
    sleep 1
    Rake::Task['attachs:refresh:missing'].invoke
    assert File.file?(image_path(:small))
    assert File.file?(image_path(:big))
    assert_not_equal original_small_time, small_time
    assert_equal original_big_time, big_time
  end

  private

  def image_path(style)
    Rails.root.join("public/#{style}/180x150.gif")
  end

  def small_time
    File.mtime(image_path(:small))
  end

  def big_time
    File.mtime(image_path(:big))
  end

end
