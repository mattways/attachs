[![Gem Version](https://badge.fury.io/rb/attachs.svg)](http://badge.fury.io/rb/attachs) [![Code Climate](https://codeclimate.com/github/museways/attachs/badges/gpa.svg)](https://codeclimate.com/github/museways/attachs) [![Build Status](https://travis-ci.org/museways/attachs.svg?branch=master)](https://travis-ci.org/museways/attachs) [![Dependency Status](https://gemnasium.com/museways/attachs.svg)](https://gemnasium.com/museways/attachs)

# Attachs

Minimalistic toolkit to attach files to records.

## Install

Put this line in your Gemfile:
```ruby
gem 'attachs'
```

Then bundle:
```
$ bundle
```

NOTE: ImageMagick is needed.

## Configuration

Generate the configuration file:
```
rails g attachs:install
```

The defaults values are:
```ruby
Attachs.configure do |config|
  config.styles = {}
  config.interpolations = {}
  config.global_styles = []
  config.global_convert_options= ''
  config.convert_options = {}
  config.default_processors = [:thumbnail]
  config.default_storage = :local
  config.default_path = '/:timestamp-:filename'
  config.base_url = ''
  config.s3 = { ssl: false }
end
```

## Usage

Add the column to your table:
```ruby
create_table :users do |t|
  t.attachment :avatar
end
```

Define the attachment in your model:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
end
```

## Paths

To customize the path to some model:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, path: '/:type/:timestamp/:filename'
end
```

To create custom interpolations:
```ruby
Attachs.configure do |config|
  config.interpolations = {
    category: -> (attachment) { attachment.record.category }
  }
end
```

NOTE: Look into lib/attachs/storages/base.rb to find a list of the system interpolations.

## Styles

Define the styles of the attachment:
```ruby
Attachs.configure do |config|
  config.styles = {
    small: '120x120!',  # forces the exact size
    medium: '240x240#', # resizes and crops to fill the desire space
    big: '360x360'      # resizes to contain the imagen in the desire space
  }
end
```

Then reference them in your model:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, styles: [:small, :medium]
end
```

To set styles for all attachments:
```ruby
Attachs.configure do |config|
  config.global_styles = [:big]
end
```

## Convert

To define global convert options:
```ruby
Attachs.configure do |config|
  config.global_convert_options = '-quality 75 -strip'
end
```

To set convert options to some styles only:
```ruby
Attachs.configure do |config|
  config.convert_options = {
    medium: '-trim'
  }
end
```

## Security

To make the attachment private:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, private: true
end
```

NOTE: Private attachments will be saved into /private folder.

## Validations

To validate the presence of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_presence_of :avatar
end
```

To validate the size of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_size_of :avatar, in: 1..5.megabytes
end
```

To validate the content type of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type_of :avatar, with: /\Aimage/
  # Or using a list
  validates_attachment_content_type_of :avatar, in: %w(image/jpg image/png)
end
```

## I18n

To translate the messages the keys are:
```
errors.messages.attachment_presence
errors.messages.attachment_size_in
errors.messages.attachment_size_less_than
errors.messages.attachment_size_greater_than
errors.messages.attachment_content_type_with
errors.messages.attachment_content_type_in
```

NOTE: Look into lib/attachs/locales yamls.

## Forms

Your forms continue to work the same:
```erb
<%= form_for @user do |f| %>
  <%= f.file_field :avatar %>
<% end %>
```

## Urls

The url method points to the original file:
```erb
<%= image_tag user.avatar.url %>
```

To point to some particular style:
```erb
<%= image_tag user.avatar.url(:small) %>
```

The defauft url is used when there is no upload:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, default_url: '/missing.png'
end
```

NOTE: If storage is s3 you can pass ssl: true to force https.

## Storage

To override the storage in the model:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, storage: :s3
end
```

To configure the s3 credentials:
```ruby
Attachs.configure do |config|
  config.s3 = {
    bucket: 'xxx',
    access_key_id: 'xxx',
    secret_access_key: 'xxx'
  }
end
```

## Processors

To create a custom processor:
```ruby
class Attachs::Processors::CustomThumbnail

  def initialize(attachment, source)
    # Custom initialization
  end

  def process(style, destination)
    # Custom logic
  end

end
```

To change the processors in the model:
```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar, processors: [:custom_thumbnail]
end
```

To change the default processors:
```ruby
Attachs.configure do |config|
  config.default_processors = [:custom_thumbnail]
end
```

## CDN

To configure a cdn:
```ruby
Attachs.configure do |config|
  config.base_url = 'http://cdn.example.com'
end
```

## Tasks

To refresh all the styles of some attachment:
```
bundle exec rake attachs:refresh:all class=user ATTACHMENT=avatar
```

To refresh missing styles of some attachment:
```
bundle exec rake attachs:refresh:missing class=user attachment=avatar
```

## Credits

This gem is maintained and funded by [museways](http://museways.com).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
