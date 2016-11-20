module Attachs
  class Configuration

    attr_accessor :convert_options, :base_url, :region, :bucket

    def interpolations
      @interpolations ||= {}
    end

  end
end
