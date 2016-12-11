module Attachs
  class Interpolations

    def exists?(name)
      registry.has_key? name
    end

    def find(name)
      if exists?(name)
        registry[name]
      else
        raise "Interpolation #{name} not found"
      end
    end

    def add(name, &block)
      registry[name] = block
    end

    private

    def registry
      @registry ||= {}
    end

  end
end
