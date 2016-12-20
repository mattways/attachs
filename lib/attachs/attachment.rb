module Attachs
  class Attachment
    include(
      ActiveModel::Validations,
      Attachs::Attachment::Attributes,
      Attachs::Attachment::Processing
    )
  end
end
