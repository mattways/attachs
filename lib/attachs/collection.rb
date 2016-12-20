module Attachs
  class Collection

    delegate(
      :map, :each, :size, :length, :count, :reject, :select, :any?, :empty?,
      :all?, :none?, :first, :second, :last, :[],
      to: :to_a
    )

    attr_reader :record, :record_attribute, :options

    def initialize(record, record_attribute, options, collection=[])
      @record = record
      @record_attribute = record_attribute
      @options = options
      @attachments = build_attachments(collection)
    end

    %i(save destroy persist unpersist).each do |name|
      define_method name do
        each do |attachment|
          attachment.send name
        end
      end
    end

    def to_a
      attachments.sort_by do |attachment|
        [(attachment.position ? 0 : 1), (attachment.position || 0)]
      end
    end
    alias_method :to_ary, :to_a

    def find(id)
      to_a.find do |attachment|
        attachment.id == id
      end
    end

    def []=(index, value)
      if attachment = to_a[index]
        attachment.assign value
      else
        append value
      end
    end

    def assign(values)
      if values.is_a?(Array)
        values.each.with_index do |value, index|
          if attachment = attachments[index]
            attachment.assign value
          else
            append value
          end
        end
      end
    end

    def append(value)
      attachment = new
      attachment.assign value
    end
    alias_method :<<, :append

    def new
      attachment = Attachment.new(record, record_attribute, options)
      attachments << attachment
      attachment
    end
    alias_method :build, :new

    private

    attr_reader :attachments

    def build_attachments(collection)
      collection.map do |attributes|
        Attachment.new record, record_attribute, options, attributes
      end
    end

  end
end
