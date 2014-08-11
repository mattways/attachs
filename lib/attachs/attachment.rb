module Attachs
  class Attachment

    attr_reader :record, :attribute, :filename, :content_type, :size, :updated_at, :upload, :options

    delegate :basename, :extension, :image?, :url, :process, :destroy, to: :type

    def initialize(record, attribute, options, source=nil)
      @record = record
      @attribute = attribute
      @options = options
      @upload = source
      if source
        @filename = source.original_filename.downcase
        @content_type = source.content_type
        @size = source.size
        @updated_at = Time.zone.now
        if record
          %w(filename content_type size updated_at).each do |name|
            record.send "#{attribute}_#{name}=", send(name)
          end
        end
      else
        %w(filename content_type size updated_at).each do |name|
          instance_variable_set :"@#{name}", record.send("#{attribute}_#{name}")
        end
      end
    end

    def styles
      @styles ||= ((options[:styles] || []) | Attachs.config.global_styles)
    end

    def private?
      @private ||= options[:private] == true
    end

    def upload?
      !upload.nil?
    end

    def exist?
      filename && size && content_type && updated_at
    end

    def blank?
      !exist?
    end

    protected

    def type
      @type ||= begin
        if exist?
          Attachs::Types::Regular.new(self)
        else
          Attachs::Types::Default.new(self)
        end
      end
    end

  end
end
