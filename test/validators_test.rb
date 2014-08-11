require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  test "presence validator" do
    model = build_model
    model.validates_attachment_presence_of :avatar
    record = model.new
    assert !record.valid?
    assert record.errors[:avatar].include?(I18n.t('errors.messages.attachment_presence'))

    record = model.new(avatar: image_upload)
    assert record.valid?
    assert record.errors[:avatar].empty?
    record.destroy
  end

  test "content type validator" do
    model = build_model
    model.validates_attachment_content_type_of :avatar, in: %w(image/gif)
    record = model.new(avatar: file_upload)
    assert !record.valid?
    assert record.errors[:avatar].include?(I18n.t('errors.messages.attachment_content_type', types: %w(image/gif).to_sentence))

    record = model.new(avatar: image_upload)
    assert record.valid?
    assert record.errors[:avatar].empty?
    record.destroy
  end

  test "size range validator" do
    model = build_model
    model.validates_attachment_size_of :avatar, in: 1..20.bytes
    record = model.new(avatar: image_upload)
    assert !record.valid?
    assert record.errors[:avatar].include?(I18n.t('errors.messages.attachment_size_in', min: number_to_human_size(1.byte), max: number_to_human_size(20.bytes)))

    record = model.new(avatar: file_upload)
    assert record.valid?
    assert record.errors[:avatar].empty?
    record.destroy
  end

  test "size minimum validator" do
    model = build_model
    model.validates_attachment_size_of :avatar, less_than: 20.bytes
    record = model.new(avatar: image_upload)
    assert !record.valid?
    assert record.errors[:avatar].include?(I18n.t('errors.messages.attachment_size_less_than', count: number_to_human_size(20.bytes)))

    record = model.new(avatar: file_upload)
    assert record.valid?
    assert record.errors[:avatar].empty?
    record.destroy
  end

  test "size maximum validator" do
    model = build_model
    model.validates_attachment_size_of :avatar, greater_than: 20.bytes
    record = model.new(avatar: file_upload)
    assert !record.valid?
    assert record.errors[:avatar].include?(I18n.t('errors.messages.attachment_size_greater_than', count: number_to_human_size(20.bytes)))

    record = model.new(avatar: image_upload)
    assert record.valid?
    assert record.errors[:avatar].empty?
    record.destroy
  end

  private

  def build_model
    Class.new(User) do
      def self.name
        'User'
      end
    end
  end

end
