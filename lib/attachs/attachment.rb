module Attachs
  class Attachment

    attr_reader :record, :attribute, :filename, :content_type, :size, :updated_at, :upload, :options

    delegate :basename, :extension, :image?, :url, :process, :destroy, :update, to: :type

    def initialize(record, attribute, options, source=false)
      @record = record
      @attribute = attribute
      @options = options
      case source
      when nil
        %w(filename content_type size updated_at).each do |name|
          record.send "#{attribute}_#{name}=", nil
        end
      when false
        %w(filename content_type size updated_at).each do |name|
          instance_variable_set :"@#{name}", record.send("#{attribute}_#{name}")
        end
      else
        load source
        %w(filename content_type size updated_at).each do |name|
          record.send "#{attribute}_#{name}=", send(name)
        end
      end
    end

    def uploaded!
      @upload = nil
    end

    def styles
      @styles ||= ((options[:styles] || []) | Attachs.config.global_styles)
    end

    def private?
      @private ||= options[:private] == true
    end

    def public?
      !private?
    end

    def upload?
      !upload.nil?
    end

    def processed?
      exists? and record.persisted? and !(
        record.send("#{attribute}_filename_changed?") or
        record.send("#{attribute}_content_type_changed?") or
        record.send("#{attribute}_size_changed?") or
        record.send("#{attribute}_updated_at_changed?")
      )
    end

    def exists?
      filename and content_type and size and updated_at
    end

    def blank?
      !exists?
    end

    def default?
      !options[:default_path].nil?
    end

    def url?
      public? and (default? or processed?)
    end

    protected

    def load(source)
      if source.is_a? URI
        download = Tempfile.new('external')
        File.open(download.path, 'wb') do |file|
          Net::HTTP.start(source.host) do |http|
            file.write http.get(source.path).body
          end
        end
        type = `file --mime-type -b '#{download.path}'`.strip
        source = ActionDispatch::Http::UploadedFile.new(
          tempfile: download,
          filename: File.basename(source.path),
          type: type
        )
      end
      if source.is_a? Attachs::Attachment
        @filename = source.filename
        @updated_at = source.updated_at
      else
        @upload = source
        @filename = source.original_filename.downcase
        @updated_at = Time.zone.now
      end
      @content_type = source.content_type
      @size = source.size
    end

    def type
      @type ||= begin
        if exists?
          Attachs::Types::Regular.new(self)
        else
          Attachs::Types::Default.new(self)
        end
      end
    end

  end
end
