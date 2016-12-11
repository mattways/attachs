module Attachs
  class Configuration

    attr_accessor :convert_options, :base_url, :region, :bucket

    def interpolation(*args, &block)
      Attachs.interpolations.add *args, &block
    end

  end
end
