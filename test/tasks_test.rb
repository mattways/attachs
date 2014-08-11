require 'test_helper'
require 'rake'

class TasksTest < ActiveSupport::TestCase

  setup do
    Dummy::Application.load_tasks
  end

  test "refresh all styles" do
    create_record
    original_small_time = small_time
    original_big_time = big_time
    ENV['CLASS'] = 'user'
    ENV['ATTACHMENT'] = 'avatar'
    sleep 1
    Rake::Task['attachs:refresh:all'].invoke
    assert File.file?(small_path)
    assert File.file?(big_path)
    assert_not_equal original_small_time, small_time
    assert_not_equal original_big_time, big_time
  end

  test "refersh missing styles" do
    create_record
    original_big_time = big_time
    File.delete small_path
    ENV['CLASS'] = 'user'
    ENV['ATTACHMENT'] = 'avatar'
    sleep 1
    Rake::Task['attachs:refresh:missing'].invoke
    assert File.file?(small_path)
    assert File.file?(big_path)
    assert_equal original_big_time, big_time
  end

  private

  attr_reader :record

  def create_record
    @record = User.create!(avatar: image_upload)
  end

  def small_path
    record.avatar.send(:type).send(:storage).send(:realpath, :small)
  end

  def big_path
    record.avatar.send(:type).send(:storage).send(:realpath, :big)
  end

  def small_time
    File.mtime(small_path)
  end

  def big_time
    File.mtime(big_path)
  end

end
