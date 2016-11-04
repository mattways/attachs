[![Gem Version](https://badge.fury.io/rb/attachs.svg)](http://badge.fury.io/rb/attachs)
[![Code Climate](https://codeclimate.com/github/mmontossi/attachs/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/attachs)
[![Build Status](https://travis-ci.org/mmontossi/attachs.svg)](https://travis-ci.org/mmontossi/attachs)
[![Dependency Status](https://gemnasium.com/mmontossi/attachs.svg)](https://gemnasium.com/mmontossi/attachs)

# Attachs

Json based attachments for records in rails.

## Install

Put this line in your Gemfile:
```ruby
gem 'attachs'
```

Then bundle:
```
$ bundle
```

To install GraphicsMagick you can use homebrew:
```
brew install graphicsmagick
```

## Configuration

Generate the configuration file:
```
rails g attachs:install
```

The available confgiurations are:
```ruby
Attachs.configure do |config|
  config.convert_options = '-strip -quality 82'
  config.region = 'us-east-1'
  config.bucket = 'some-bucket'
  config.base_url = 'https://cdn.mydomain.com'
end
```

## Definition

Add the columns to your tables:
```ruby
class AddAttachments < ActiveRecord::Migration
  def change
    add_attachment :shops, :logo
    add_attachments :products, :pictures
  end
end
```

Define the attachments in your models:
```ruby
class Shop < ActiveRecord::Base
  has_attachment(
    :logo,
    path: 'logos/:id.png',
    default_path: '/missing.png'
  )
end

class Product < ActiveRecord::Base
  has_attachment(
    :pictures,
    path: 'products/:id-:style.:extension',
    styles: {
      tiny: '25x25',
      small: '150x150#',
      medium: '300x300!',
      large: '600x'
    }
  )
end
```

## Paths

To customize the path to some model:
```ruby
class Shop < ActiveRecord::Base
  has_attachment :logo, path: '/:logo/:name/:id.png'
end
```

To create custom interpolations:
```ruby
Attachs.configure do |config|
  config.interpolations[:name] = Proc.new do |record|
    record.name
  end
end
```

NOTE: The available interpolations are: filename, basename, extension, attribute, content_type, size.

## Validations

To validate the presence of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attachment :pictures
  validates_attachment_presence_of :pictures
end
```

To validate the size of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attachment :pictures
  validates_attachment_size_of :pictures, in: 1..5.megabytes
end
```

To validate the content type of the attachment:
```ruby
class User < ActiveRecord::Base
  has_attachment :pictures
  validates_attachment_content_type_of :pictures, with: /\Aimage/
end

```
NOTE: Look into lib/attachs/locales yamls to known the keys.

## Forms

Your forms continue to work the same:
```erb
<%= form_for @shop do |f| %>
  <%= f.file_field :logo %>
<% end %>
```

You can manage collections with fields_for:
```erb
<%= form_for @product do |f| %>
  <%= f.fields_for :pictures do |ff| %>
    <%= ff.file_field :value %>
    <%= ff.number_field :position %>
  <% end %>
<% end %>
```

## Urls

The url method points to the original file:
```erb
<%= image_tag shop.logo.url %>
```

To point to some particular style:
```erb
<%= image_tag shop.logo.url(:small) %>
```

## Tasks

To reprocess all styles:
```
bundle exec rake attachs:reprocess
```

To fix missing styles:
```
bundle exec rake attachs:fix_missings
```

To remove orphan files:
```
bundle exec rake attachs:clear
```

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
