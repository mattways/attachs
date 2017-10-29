module Attachs
  class Attachment < ActiveRecord::Base

    ALPHABET = 'abcdefghijklmnopqrstuvwxyz0123456789'
    ENCODING = '8kluw1mtri2xncsp649obvezgd57qy3fj0ah'
    STATES = %w(uploading processing processed)

    self.table_name = 'attachments'

    before_validation :ensure_requested_at, on: :create
    after_commit :delete_files, on: :destroy

    scope :attached, -> { where.not(record_id: nil) }
    scope :unattached, -> { where(record_id: nil) }
    scope :uploaded, -> { where.not(state: 'uploading') }
    scope :unprocessed, -> { where.not(state: 'processed') }

    STATES.each do |name|
      scope name, -> { where(state: name) }
    end

    belongs_to :record, polymorphic: true, required: false

    validates_presence_of :record_type, :record_attribute, :requested_at
    validate :record_type_must_be_valid, :record_attribute_must_be_valid, :record_must_not_change
    validate :must_be_processed, if: :attached?

    with_options if: :processed? do |a|
      a.validates_presence_of :extension, :content_type, :size, :processed_at
      a.validates_numericality_of :size, greater_than: 0, only_integer: true
      a.validates_time_of :processed_at, after: :requested_at
    end

    STATES.each do |name|
      define_method "#{name}?" do
        state == name
      end
      define_method "#{name}!" do
        update! state: name
      end
    end

    def attached?
      record.present?
    end

    def unattached?
      !attached?
    end

    def unprocessed?
      !processed?
    end

    def uploaded?
      !uploading?
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

    def url(style=nil)
      style ||= :original
      if styles.include?(style) && path = generate_path(style)
        storage.url path
      end
    end

    def urls
      hash = generate_paths
      hash.each do |style, path|
        hash[style] = storage.url(path)
      end
      hash
    end

    def process
      unless processed?
        file = storage.fetch(id.to_s)
        self.size = file.size
        self.content_type = Console.detect_content_type(file.path)
        self.extension = MIME::Types[content_type].first.extensions.first
        self.state = 'processed'
        self.processed_at = Time.zone.now
        configuration.callbacks.process :before, file, self
        storage.process file.path, generate_paths, content_type, style_options
        configuration.callbacks.process :after, file, self
        save
      end
    end

    def reprocess
      if processed?
        upload = storage.fetch(current_paths[:original])
        new_paths = generate_paths
        (paths.values - new_paths.values).each do |path|
          self.old_paths |= [path]
        end
        (new_paths.values - paths.values).each do |path|
          storage.delete path
        end
        self.current_paths = new_paths
        storage.process upload.path, paths, content_type, style_optionss
        self.processed_at = Time.zone.now
        save
        record.touch
      end
    end

    def fix_missings
      if processed?
        missing_paths = {}
        paths.except(:original).each do |style, path|
          unless storage.exists?(path)
            missing_paths[style] = path
          end
        end
        if missing_paths.any?
          upload = storage.fetch(current_paths[:original])
          storage.process upload.path, missing_paths, content_type, style_options
          record.touch
        end
      end
    end

    def persistable?
      if new_record? && (changed - %w(record_id record_type record_attribute)).none?
        false
      else
        true
      end
    end

    def changed_for_autosave?
      if !persistable?
        false
      else
        super
      end
    end

    def respond_to_missing?(name, include_private=false)
      name.to_s.ends_with?('=') || extras.has_key?(name) || super
    end

    def method_missing(name, *args, &block)
      if name.to_s.ends_with?('=')
        extras[name.to_s[0..-2]] = args.first
      elsif extras.has_key?(name.to_s)
        extras[name.to_s]
      else
        super
      end
    end

    private

    %i(storage configuration).each do |name|
      define_method name do
        Attachs.send name
      end
    end

    def record_type_must_be_valid
      unless record_model.try(:attachable?)
        errors.add :record_type, :invalid
      end
    end

    def record_attribute_must_be_valid
      unless record_model.try(:has_attachment?, record_attribute)
        errors.add :record_attribute, :invalid
      end
    end

    def record_must_not_change
      %w(record_id record_type record_attribute).each do |attribute|
        if send("#{attribute}_was").present? && send("#{attribute}_changed?")
          errors.add attribute, :immutable
        end
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
          storage.delete path(style)
        end
      else
        storage.delete id
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

    def style_options
      options.fetch :styles, {}
    end

    def styles
      [:original] + options.fetch(:styles, {}).keys
    end

    def generate_path(style)
      if processed?
        "#{id}/#{ofuscate(style).parameterize}" + ".#{extension}"
      else
        options[:default_path]
      end
    end

    def generate_paths
      hash = {}
      styles.each do |style|
        if path = generate_path(style)
          hash[style] = path
        end
      end
      hash
    end

    def ofuscate(value)
      value.to_s.tr ALPHABET, ENCODING
    end

    def ensure_requested_at
      self.requested_at ||= Time.zone.now
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

      private

      def storage
        Attachs.storage
      end

    end
  end
end
