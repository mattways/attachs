module Attachs
  class Callbacks

    NAMES = %i(after_join)

    def process(name, path, attachment)
      if registry.has_key?(name)
        registry[name].each do |expression, blocks|
          if attachment.content_type =~ expression
            blocks.each do |block|
              block.call path, attachment
            end
          end
        end
      end
    end

    def add(name, expression, &block)
      if NAMES.include?(name)
        (registry[name][expression] ||= []) << block
      else
        raise CallbackNotFound
      end
    end

    private

    def registry
      @registry ||= begin
        hash = {}
        NAMES.each do |name|
          hash[name] = {}
        end
        hash
      end
    end

  end
end
