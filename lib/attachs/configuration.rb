module Attachs
  class Configuration

    attr_accessor(
      :convert_options,
      :base_url,
      :fallback,
      :maximum_size,
      :default_styles
    )

    def callbacks
      @callbacks ||= Callbacks.new
    end

    def interpolations
      @interpolations ||= Interpolations.new
    end

    def interpolation(*args, &block)
      interpolations.add *args, &block
    end

    %i(after_join).each do |name|
      define_method name do |expression, &block|
        callbacks.add name, expression, &block
      end
    end

  end
end
