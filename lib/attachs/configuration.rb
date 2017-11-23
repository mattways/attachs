module Attachs
  class Configuration

    attr_accessor(
      :convert_options,
      :base_url,
      :prefix,
      :region,
      :bucket,
      :cache_control_header,
      :expires_header,
      :access_key_id,
      :secret_access_key,
      :maximum_size_policy,
      :expiration_policy
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
