module Attachs
  class Attachment
    module Processing
      extend ActiveSupport::Concern

      def url(style=:original)
        paths = attributes[:paths]
        if paths.has_key?(style)
          storage.url paths[style]
        elsif options.has_key?(:default_path)
          template = options[:default_path]
          path = generate_path(template, style)
          storage.url path
        end
      end

      def assign(value)
        source, new_attributes = normalize_value(value)
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
          attributes[:uploaded_at] = original_attributes[:uploaded_at]
          write_record
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
          if source.is_a?(Attachment)
            file = storage.get(source.paths[:original])
            storage.process file, paths, styles
          elsif source.is_a?(ActionDispatch::Http::UploadedFile)
            storage.process source, paths, styles
          elsif source.class.name == 'Upload'
            source.file.paths.each do |style, path|
              storage.copy path, paths[style]
            end
          end
          @source = @value = nil
          @original_attributes = @attributes
        elsif present?
          if paths != generate_paths
            Jobs::UpdateJob.perform_later record, record_attribute.to_s
          end
        end
      end

      def destroy
        assign nil
        save
      end

      def _destroy=(value)
        if ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
          assign nil
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
                unless storage.exists?(new_path)
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
            if storage.exists?(path)
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
            unless storage.exists?(path)
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

      private

      def storage
        Attachs.storage
      end

      def update_record(value=nil)
        unless record.destroyed?
          record.update_column record_attribute, (value || raw_attributes)
        end
      end

      def generate_path(template, style)
        if path = template.try(:dup)
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
        template = options[:path]
        paths = { original: generate_path(template, :original) }
        styles.each do |style, geometry|
          paths[style] = generate_path(template, style)
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

      def build_attributes(value)
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
        attributes
      end

      def normalize_value(value)
        if value.blank?
          [nil, {}]
        elsif value.is_a?(ActionDispatch::Http::UploadedFile)
          [value, build_attributes(value)]
        elsif value.is_a?(Attachment)
          [value, value.attributes.merge(id: generate_id)]
        elsif value.class.name == 'Upload'
          [value, value.file.attributes.merge(id: generate_id)]
        else
          if Rails.configuration.cache_classes == false
            Rails.application.eager_load!
          end
          if defined?(Upload)
            upload = Upload.find(value)
            [upload, upload.file.attributes.merge(id: generate_id)]
          end
        end
      end

    end
  end
end
