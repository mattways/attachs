module Attachs
  class Attachment
    include ActiveModel::Validations

    attr_reader :record, :record_attribute, :options, :attributes, :value

    def initialize(record, record_attribute, options={}, attributes={})
      @record = record
      @record_attribute = record_attribute
      @options = options
      @original_attributes = @attributes = normalize_attributes(attributes)
    end

    %i(id size filename content_type uploaded_at).each do |name|
      define_method name do
        attributes[name]
      end
    end

    def basename
      if filename
        File.basename filename, extension
      end
    end

    def extension
      if filename
        File.extname filename
      end
    end

    def present?
      filename.present? && content_type.present? && size.present?
    end

    def blank?
      !present?
    end

    def persisted?
      record.persisted? && paths.any? && uploaded_at
    end

    def changed?
      @original_attributes != @attributes
    end

    def type
      if content_type
        if content_type.starts_with?('image/')
          'image'
        else
          'file'
        end
      end
    end

    def url(style=:original)
      if path = attributes[:paths][style]
        storage.url path
      end
    end

    def position
      if options[:multiple]
        attributes[:position]
      end
    end

    def position=(value)
      if options[:multiple]
        attributes[:position] = value
        write_record
      end
    end

    def assign(value)
      source, new_attributes = process_value(value)
      if new_attributes
        unless changed?
          @original_attributes = attributes
        end
        @attributes = new_attributes
        write_record
        @source = source
        @value = value
      end
    end
    alias_method :value=, :assign

    def _destroy=(value)
      if ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        assign nil
      end
    end

    def save
      if changed?
        if original_attributes[:paths].any? || original_attributes[:old_paths].any?
          Jobs::DeleteJob.perform_later(
            original_attributes[:paths].values +
            original_attributes[:old_paths]
          )
        end
        case source.class.name
        when 'Attachs::Attachment'
          file = storage.get(source.paths[:original])
          storage.process file, paths, styles
        when 'Upload'
          source.file.paths.each do |style, path|
            storage.copy path, paths[style]
          end
        when 'ActionDispatch::Http::UploadedFile'
          storage.process source, paths, styles
        end
        @source = @value = nil
        @original_attributes = @attributes
      elsif present?
        if paths != generate_paths
          Jobs::UpdateJob.perform_later record, record_attribute.to_s
        end
      end
    end

    def update_paths
      if changed?
        raise 'Save attachment before update paths'
      else
        new_paths = generate_paths
        if paths != new_paths
          new_paths.each do |style, new_path|
            original_path = paths[style]
            if original_path != new_path
              unless storage.exist?(new_path)
                storage.copy original_path, new_path
              end
              attributes[:paths][style] = new_path
              attributes[:old_paths] |= [original_path]
            end
          end
          update_record
        end
      end
    end

    def reprocess
      if changed?
        raise 'Save attachment before reprocess'
      elsif present? && styles
        file = storage.get(paths[:original])
        paths.each do |style, path|
          if storage.exist?(path)
            storage.delete path
          end
          Rails.logger.info "Regenerating: #{style} => #{path}"
        end
        new_paths = generate_paths
        storage.process file, new_paths, styles
        attributes[:paths] = new_paths
        update_record
      end
    end

    def fix_missings
      if changed?
        raise 'Save attachment before fix missings'
      elsif present? && styles
        missings = paths.slice(:original)
        paths.except(:original).each do |style, path|
          unless storage.exist?(path)
            missings[style] = path
            Rails.logger.info "Generating: #{style} => #{path}"
          end
        end
        if missings.size > 1
          file = storage.get(paths[:original])
          storage.process file, missings, styles
        end
      end
    end

    def destroy
      assign nil
      save
    end

    def method_missing(name, *args, &block)
      if attributes.has_key?(name)
        attributes[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private=false)
      attributes.has_key?(name) || super
    end

    def persist
      if changed? && present?
        new_paths = generate_paths
        if paths != new_paths
          attributes[:paths] = new_paths
          attributes[:uploaded_at] = Time.now
          write_record
        end
      end
    end

    def unpersist
      if changed? && present?
        attributes[:paths] = original_attributes[:paths]
        attributes[:uploaded_at] = original_attributes[:paths]
        write_record
      end
    end

    def styles
      case value = options[:styles]
      when Proc
        value.call(record) || {}
      when Hash
        value
      else
        {}
      end
    end

    private

    attr_reader :original_attributes, :source

    def storage
      Attachs.storage
    end

    def normalize_attributes(attributes)
      attributes.reverse_merge(paths: {}, old_paths: []).deep_symbolize_keys
    end

    def write_record(value=nil)
      unless record.destroyed?
        record.send "#{record_attribute}_will_change!"
        record.send :write_attribute, record_attribute, (value || raw_attributes)
      end
    end

    def raw_attributes
      if options[:multiple]
        record.send(:read_attribute, record_attribute).reject{ |h| h['id'] == id }.append attributes
      else
        attributes
      end
    end

    def update_record(value=nil)
      unless record.destroyed?
        record.update_column record_attribute, (value || raw_attributes)
      end
    end

    def find_template_path(style)
      if present?
        options[:path]
      else
        options[:default_path]
      end
    end

    def generate_path(style)
      if path = find_template_path(style).try(:dup)
        path.gsub! ':style', style.to_s.gsub('_', '-')
        path.scan(/:[a-z_]+/).each do |token|
          name = token.from(1).to_sym
          path.gsub! token, interpolate(name).to_s.parameterize
        end
        path.squeeze! '-'
        path.squeeze! '/'
        path.gsub! '-.', '.'
        path.gsub! '/-', '/'
        path.gsub! '-/', '/'
        path.sub! /^\//, ''
        path
      end
    end

    def generate_paths
      paths = { original: generate_path(:original) }
      styles.each do |style, geometry|
        paths[style] = generate_path(style)
      end
      paths
    end

    def interpolate(name)
      if %i(basename extension).include?(name)
        send name
      elsif name == :attribute
        record_attribute
      elsif attributes.except(:upload_at, :paths, :old_paths).has_key?(name)
        attributes[name]
      else
        Attachs.interpolations.find(name).call record
      end
    end

    def generate_id
      SecureRandom.uuid.gsub '-', ''
    end

    def process_value(value)
      case value.class.name
      when 'NilClass'
        [nil, {}]
      when 'Attachs::Attachment'
        attributes = value.attributes.merge(id: generate_id)
        [value, attributes]
      when 'Upload'
        attributes = value.file.attributes.merge(id: generate_id)
        [value.file, attributes]
      when 'String','Fixnum','Bignum'
        if Rails.configuration.cache_classes == false
          Rails.application.eager_load!
        end
        if defined?(Upload)
          upload = Upload.find(value)
          attributes = upload.file.attributes.merge(id: generate_id)
          [upload, attributes]
        end
      when 'ActionDispatch::Http::UploadedFile'
        attributes = {
          id: generate_id,
          filename: value.original_filename,
          content_type: value.content_type,
          size: value.size.to_i,
          uploaded_at: Time.now,
          paths: {},
          old_paths: []
        }
        if value.content_type.starts_with?('image/')
          width, height = Console.find_dimensions(value.path)
          attributes[:width] = width
          attributes[:height] = height
          attributes[:ratio] = (height.to_d / width.to_d).to_f
        end
        [value, attributes]
      end
    end

  end
end
