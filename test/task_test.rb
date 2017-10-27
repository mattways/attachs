require 'test_helper'
load File.expand_path('../../lib/tasks/attachs.rake', __FILE__)
Rake::Task.define_task :environment

class TaskTest < ActiveSupport::TestCase

  test 'clear' do
    Attachs.expects(:clear).with.once
    Rake::Task['attachs:clear'].invoke
  end

  test 'reprocess' do
    Attachs.expects(:reprocess).with.once
    Rake::Task['attachs:reprocess'].invoke
  end

  test 'fix missings' do
    Attachs.expects(:fix_missings).with.once
    Rake::Task['attachs:fix_missings'].invoke
  end

end
