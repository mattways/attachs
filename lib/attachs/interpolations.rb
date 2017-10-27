module Attachs
  class Interpolations

    RESERVED_NAMES = %i(id extension)

    def exists?(name)
      registry.has_key? name
    end

    def process(name, record)
      if exists?(name)
        registry[name].call record
      else
        raise "Interpolation #{name} not found"
      end
    end

    def add(name, &block)
      if RESERVED_NAMES.include?(name)
        raise "Interpolation #{name} is reserved"
      elsif exists?(name)
        raise "Interpolation #{name} already exists"
      else
        registry[name] = block
      end
    end

    private

    def registry
      @registry ||= {}
    end

  end
end
