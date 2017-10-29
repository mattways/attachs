require 'test_helper'

class InterpolationTest < ActiveSupport::TestCase

  test 'exists' do
    assert interpolations.exists?(:name)
    assert_not interpolations.exists?(:other)
  end

  test 'process' do
    business = build(:business)

    assert_raises Attachs::InterpolationNotFound do
      interpolations.process :other, business
    end
    assert_equal 'Test', interpolations.process(:name, business)
  end

  test 'add' do
    %i(id extension).each do |name|
      assert_raises Attachs::InterpolationReserved do
        interpolations.add name do |record|
        end
      end
    end
    assert_raises Attachs::InterpolationExists do
      interpolations.add :name do |record|
      end
    end
  end

  private

  def interpolations
    Attachs.configuration.interpolations
  end

end
