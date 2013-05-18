require 'rails_uploads/active_record/base'
require 'rails_uploads/magick/image'
require 'rails_uploads/storages/local'
require 'rails_uploads/storages/s3'
require 'rails_uploads/types/file'
require 'rails_uploads/types/image'
require 'rails_uploads/validators/base'
require 'rails_uploads/validators/attachment_content_type_validator'
require 'rails_uploads/validators/attachment_presence_validator'
require 'rails_uploads/validators/attachment_size_validator'
require 'rails_uploads/engine'
require 'rails_uploads/railtie'
require 'rails_uploads/version'

module RailsUploads
end
