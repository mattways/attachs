module Attachs
  class Interpolations

    RESERVED = %i(id extension)

    def exists?(name)
      registry.has_key? name
    end

    def process(name, attachable)
      if exists?(name)
        registry[name].call attachable
      else
        raise InterpolationNotFound
      end
    end

    def add(name, &block)
      if RESERVED.include?(name)
        raise InterpolationReserved
      elsif exists?(name)
        raise InterpolationExists
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
