module Attachs
  class Attachment < ActiveRecord::Base

    self.table_name = 'attachments'

    after_commit :process_upload, on: :create
    after_commit :delete_files, on: :destroy

    scope :attached, -> { where.not(record_id: nil) }
    scope :unattached, -> { where(record_id: nil) }
    scope :processed, -> { where.not(processed_at: nil) }
    scope :unprocessed, -> { where(processed_at: nil) }

    belongs_to :record, polymorphic: true, required: false

    validates_presence_of :record_type, :record_base, :record_attribute
    validate :record_type_must_be_valid, :record_base_must_be_valid, :record_attribute_must_be_valid

    with_options if: :attached? do
      validate :must_be_processed
    end

    with_options if: :processed? do
      validates_presence_of :extension, :content_type, :size
      validates_numericality_of :size, greater_than: 0, only_integer: true
    end

    attr_accessor :upload

    def unattached?
      record_id.nil?
    end

    def attached?
      !unattached?
    end

    def unprocessed?
      processed_at.nil?
    end

    def processed?
      !unprocessed?
    end

    def record_type=(value)
      if value
        self.record_base = value.constantize.base_class 
      end
      super value
    end

    def description
      if attached?
        key = "attachments.#{record_type.underscore}.#{record_attribute}"
        if I18n.exists?(key)
          I18n.t(key).gsub(/%\{[^\}]+\}/) do |match|
            interpolate match.remove(/%\{|\}/).to_sym
          end
        end
      end
    end

    def url(style=:original)
      storage.url generate_path(style, unprocessed?)
    end

    def urls
      hash = {}
      generate_paths(unprocessed?).each do |style, path|
        hash[style] = storage.url(path)
      end
      hash
    end

    def process(path)
      if unprocessed?
        self.size = File.size(path) 
        self.content_type = Console.content_type(path)
        self.extension = MIME::Types[content_type].first.extensions.first
        self.processed_at = Time.now
        configuration.callbacks.process :before_process, path, self
        storage.process id, path, generate_paths, content_type, styles_options
        configuration.callbacks.process :after_process, path, self
        save
      end
    end

    def saveable?
      persisted? || !upload.nil?
    end
    alias_method :validable?, :saveable?

    def unsaveable?
      !saveable?
    end
    alias_method :unvalidable?, :unsaveable?

    def changed_for_autosave?
      unsaveable? ? false : super
    end

    private

    delegate :storage, :configuration, to: :Attachs

    def process_upload
      ProcessJob.perform_later upload.path, self
    end

    def respond_to_missing?(name, include_private=false)
      metadata.has_key?(name) || super
    end

    def method_missing(name, *args, &block)
      if metadata.has_key?(name.to_s)
        metadata[name.to_s]
      else
        super
      end
    end

    def record_type_must_be_valid
      unless record_model.try(:attachable?)
        errors.add :record_type, :invalid
      end
    end

    def record_base_must_be_valid
      if record_model.base_class != record_base.safe_constantize
        errors.add :record_base, :invalid
      end
    end

    def record_attribute_must_be_valid
      unless record_model.try(:has_attachment?, record_attribute)
        errors.add :record_attribute, :invalid
      end
    end

    def must_be_processed
      unless processed?
        errors.add :base, :unprocessed
      end
    end

    def delete_files
      if processed?
        styles.each do |style|
          storage.delete generate_path(style)
        end
      end
    end

    def record_model
      if record_type.present?
        record_type.classify.safe_constantize
      end
    end

    def options
      if record_model.present? && record_attribute.present?
        record_model.attachments[record_attribute.to_sym]
      else
        {}
      end
    end

    def styles_options
      options.fetch :styles, {}
    end

    def styles
      [:original] + styles_options.keys
    end

    def generate_path(style, fallback=false)
      if fallback
        template = (options[:fallback] || configuration.fallback)
        template.gsub ':style', style.to_s
      else
        name = obfuscate(style)
        "#{id}/#{name}.#{extension}"
      end
    end

    def obfuscate(style)
      alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789_'
      encoding = '8kluw1mtri2xncsp649obvezgd57qy3fj0ahx'
      style.to_s.tr alphabet, encoding
    end

    def generate_paths(fallback=false)
      hash = {}
      styles.each do |style|
        hash[style] = generate_path(style, fallback)
      end
      hash
    end

    def interpolate(name)
      if configuration.interpolations.exists?(name)
        configuration.interpolations.process name, record
      elsif record.respond_to?(name)
        record.send name
      end
    end

    class << self

      def clear
        unattached.where('request_at < ?', (Time.zone.now - 1.day)).find_each &:destroy
      end

      %i(reprocess fix_missings).each do |name|
        define_method name do
          processed.find_each do |attachment|
            attachment.send name
          end
        end
      end

    end
  end
end
