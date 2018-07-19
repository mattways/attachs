module Attachs
  class Attachment < ActiveRecord::Base

    self.table_name = 'attachments'

    after_destroy :delete_files

    scope :attached, -> { where.not(record_id: nil) }
    scope :unattached, -> { where(record_id: nil) }

    belongs_to :record, polymorphic: true, required: false

    with_options if: :attached? do
      validates_presence_of :record_type, :record_base, :record_attribute
      validate :record_type_must_be_valid, :record_base_must_be_valid, :record_attribute_must_be_valid, :must_be_processed
    end

    with_options if: :processed? do
      validates_presence_of :extension, :content_type, :size
      validates_numericality_of :size, greater_than: 0, only_integer: true
    end

    def unattached?
      record_id.nil?
    end

    def attached?
      !unattached?
    end

    def unprocessed?
      !processed?
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
      if processed?
        slug = build_slug(style)
        "#{Attachs.configuration.base_url}/storage/#{slug}"
      else
        template = (options[:fallback] || configuration.fallback)
        slug = template.gsub(':style', style.to_s)
        ActionController::Base.helpers.image_path slug
      end
    end

    def urls
      hash = {}
      styles.each do |style|
        hash[style] = url(style)
      end
      hash
    end

    def saveable?
      persisted?
    end
    alias_method :validable?, :saveable?

    def unsaveable?
      !saveable?
    end
    alias_method :unvalidable?, :unsaveable?

    def changed_for_autosave?
      unsaveable? ? false : super
    end

    def store(chunk, path)
      storage.store id, chunk, path
    end

    def join
      self.size, self.content_type, self.extension, path = storage.join(id, generate_hash(:original))
      configuration.callbacks.process :after_join, path, self
      self.processed = true
      save!
    end

    def process(style)
      storage.process build_slug(:original), build_slug(style), content_type, styles_options[style]
    end

    def ensure_style(hash, format)
      style = styles.find do |style|
        hash == generate_hash(style)
      end
      if style
        slug = build_slug(style)
        if File.extname(slug)[1..-1] == format && !storage.exists?(slug)
          process style
        end
        storage.path slug
      end
    end

    private

    delegate :storage, :configuration, to: :Attachs

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

    def must_be_processed
      unless processed?
        errors.add :processed, :invalid
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

    def delete_files
      if processed?
        styles.each do |style|
          storage.delete build_slug(style)
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

    def default_styles
      configuration.default_styles || {}
    end

    def styles_options
      options.fetch(:styles, {}).merge default_styles
    end

    def styles
      [:original] + styles_options.keys
    end

    def generate_hash(style)
      options = styles_options[style]
      Digest::MD5.hexdigest("#{id}#{style}#{options}").to_i(16).to_s(36)
    end

    def build_slug(style)
      hash = generate_hash(style)
      "#{id}/#{hash}.#{extension}"
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

    end
  end
end
