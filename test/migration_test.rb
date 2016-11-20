require 'test_helper'

class MigrationTest < ActiveSupport::TestCase

  test 'column' do
    ActiveRecord::Migration.verbose = false
    paths = Rails.application.paths['db/migrate'].to_a
    assert_nothing_raised do
      ActiveRecord::Migrator.migrate paths, 0
      ActiveRecord::Migrator.migrate paths, nil
    end
  end

end
