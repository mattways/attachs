require 'test_helper'

class InterpolationTest < ActiveSupport::TestCase

  test 'exists' do
    assert interpolations.exists?(:name)
    assert_not interpolations.exists?(:other)
  end

  test 'process' do
    business = Business.new(name: 'test')

    assert_raises_message 'Interpolation other not found' do
      interpolations.process :other, business
    end
    assert_equal 'test', interpolations.process(:name, business)
  end

  test 'add' do
    %i(id extension).each do |name|
      assert_raises_message "Interpolation #{name} is reserved" do
        interpolations.add name do |record|
        end
      end
    end
    assert_raises_message 'Interpolation name already exists' do
      interpolations.add :name do |record|
      end
    end
  end

  private

  def interpolations
    Attachs.configuration.interpolations
  end

end
