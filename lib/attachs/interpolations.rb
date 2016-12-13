module Attachs
  class Interpolations

    def find(name)
      if registry.has_key?(name)
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
