module Attachs
  class Configuration

    attr_accessor(
      :convert_options,
      :base_url,
      :fallback,
      :prefix,
      :maximum_size
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

    %i(before_process after_process).each do |name|
      define_method name do |expression, &block|
        callbacks.add name, expression, &block
      end
    end

  end
end
