module Attachs

  class Error < StandardError
  end

  class CallbackNotFound < Error
  end

  class InterpolationNotFound < Error
  end

  class InterpolationExists < Error
  end

end
